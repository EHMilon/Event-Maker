/// WebSocket Service for real-time communication.
///
/// Features:
/// - Connection lifecycle management
/// - Automatic reconnection with exponential backoff
/// - Heartbeat/ping-pong for connection health
/// - Event-based message handling
/// - Offline message queueing
///
/// Backend developer: This service is ready to connect to your WebSocket server.
/// Just update [ApiConstant.wsBaseUrl] with your WebSocket endpoint.

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/websocket_events.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:event_maker/utils/user_preferences.dart';

/// WebSocket connection states.
enum WsConnectionState {
  /// Not connected, not attempting to connect
  disconnected,

  /// Attempting to connect
  connecting,

  /// Connected and authenticated
  connected,

  /// Connection lost, attempting to reconnect
  reconnecting,

  /// Authentication failed
  authFailed,

  /// Connection error
  error,
}

/// WebSocket service for real-time chat communication.
///
/// Usage:
/// ```dart
/// final wsService = WebSocketService();
///
/// // Listen to connection state
/// wsService.connectionStateStream.listen((state) {
///   if (state == WsConnectionState.connected) {
///     print('Connected to WebSocket');
///   }
/// });
///
/// // Listen to events
/// wsService.eventStream.listen((event) {
///   if (event is MessageReceivedEvent) {
///     print('New message: ${event.message.content}');
///   }
/// });
///
/// // Connect
/// await wsService.connect();
///
/// // Send message
/// wsService.send(SendMessageEvent(chatId: '123', content: 'Hello'));
///
/// // Disconnect when done
/// wsService.disconnect();
/// ```
class WebSocketService {
  /// Singleton instance
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  // ===== WEBSOCKET CHANNEL =====
  WebSocketChannel? _channel;

  // ===== STREAM CONTROLLERS =====
  final _connectionStateController =
      StreamController<WsConnectionState>.broadcast();
  final _eventController = StreamController<WsEvent>.broadcast();

  // ===== STATE =====
  WsConnectionState _connectionState = WsConnectionState.disconnected;
  String? _authToken;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isManualDisconnect = false;

  // ===== PENDING MESSAGES QUEUE =====
  /// Messages queued while offline or reconnecting
  final List<WsEvent> _pendingMessages = [];

  // ===== PUBLIC GETTERS =====

  /// Current connection state
  WsConnectionState get connectionState => _connectionState;

  /// Stream of connection state changes
  Stream<WsConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// Stream of all WebSocket events
  Stream<WsEvent> get eventStream => _eventController.stream;

  /// Whether currently connected and authenticated
  bool get isConnected => _connectionState == WsConnectionState.connected;

  /// Whether currently attempting to connect or reconnect
  bool get isConnecting =>
      _connectionState == WsConnectionState.connecting ||
      _connectionState == WsConnectionState.reconnecting;

  // ===== CONNECTION MANAGEMENT =====

  /// Connect to WebSocket server.
  ///
  /// If [token] is provided, it will be used for authentication.
  /// Otherwise, token is fetched from [UserPreferences].
  ///
  /// Returns true if connected successfully, false otherwise.
  Future<bool> connect({String? token}) async {
    if (isConnected || isConnecting) {
      Log.w('WebSocket: Already connected or connecting');
      return isConnected;
    }

    _authToken = token ?? await UserPreferences.getAccessToken();
    if (_authToken == null) {
      Log.e('WebSocket: No auth token available');
      _updateConnectionState(WsConnectionState.authFailed);
      return false;
    }

    _isManualDisconnect = false;
    _updateConnectionState(WsConnectionState.connecting);

    try {
      final uri = Uri.parse(ApiConstant.wsBaseUrl);
      Log.d('WebSocket: Connecting to ${uri.host}');

      _channel = WebSocketChannel.connect(uri, protocols: ['json']);

      // Wait for connection to establish
      await _channel!.ready.timeout(
        Duration(milliseconds: ApiConstant.wsConnectionTimeout),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timeout');
        },
      );

      Log.d('WebSocket: Connected, authenticating');
      _setupListeners();
      _authenticate();
      return true;
    } catch (e) {
      Log.e('WebSocket: Connection failed', e);
      _updateConnectionState(WsConnectionState.error);
      _scheduleReconnect();
      return false;
    }
  }

  /// Disconnect from WebSocket server.
  ///
  /// If [reconnect] is true, will attempt to reconnect.
  /// If [isManual] is true, won't auto-reconnect.
  void disconnect({bool reconnect = false, bool isManual = false}) {
    _isManualDisconnect = isManual;

    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    if (reconnect) {
      _updateConnectionState(WsConnectionState.reconnecting);
    } else {
      _updateConnectionState(WsConnectionState.disconnected);
    }

    try {
      _channel?.sink.close(ws_status.goingAway);
    } catch (e) {
      Log.e('WebSocket: Error closing connection', e);
    }
    _channel = null;

    if (reconnect && !_isManualDisconnect) {
      _scheduleReconnect();
    }
  }

  /// Manually trigger reconnection.
  Future<void> reconnect() async {
    disconnect(reconnect: true);
    await connect();
  }

  // ===== AUTHENTICATION =====

  /// Send authentication event to server.
  void _authenticate() {
    if (_authToken == null) return;

    final authEvent = AuthEvent(token: 'Bearer $_authToken');
    _sendRaw(authEvent.toJson());
  }

  // ===== MESSAGE SENDING =====

  /// Send a WebSocket event.
  ///
  /// If not connected, message is queued and sent when reconnected.
  void send(WsEvent event) {
    if (!isConnected) {
      Log.w('WebSocket: Not connected, queuing message');
      _pendingMessages.add(event);
      return;
    }

    _sendRaw(event.toJson());
  }

  /// Send raw JSON to WebSocket.
  void _sendRaw(Map<String, dynamic> data) {
    try {
      final jsonStr = jsonEncode(data);
      Log.d('WebSocket: Sending ${data['type']}');
      _channel?.sink.add(jsonStr);
    } catch (e) {
      Log.e('WebSocket: Failed to send message', e);
    }
  }

  /// Send all pending messages.
  void _flushPendingMessages() {
    if (_pendingMessages.isEmpty) return;

    Log.d('WebSocket: Sending ${_pendingMessages.length} pending messages');
    for (final event in _pendingMessages) {
      send(event);
    }
    _pendingMessages.clear();
  }

  // ===== LISTENERS =====

  /// Setup WebSocket message listeners.
  void _setupListeners() {
    _channel?.stream.listen(_onMessage, onError: _onError, onDone: _onDone);
  }

  /// Handle incoming WebSocket message.
  void _onMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;
      final event = WsEvent.fromJson(json);

      Log.d('WebSocket: Received event ${event.type}');

      // Handle internal events
      _handleInternalEvent(event);

      // Emit to public stream
      _eventController.add(event);
    } catch (e) {
      Log.e('WebSocket: Failed to parse message', e);
    }
  }

  /// Handle internal events (authentication, heartbeat).
  void _handleInternalEvent(WsEvent event) {
    switch (event.type) {
      case WsEventType.authenticated:
        Log.d('WebSocket: Authenticated successfully');
        _updateConnectionState(WsConnectionState.connected);
        _reconnectAttempts = 0;
        _startHeartbeat();
        _flushPendingMessages();
        break;

      case WsEventType.pong:
        // Heartbeat response - connection is alive
        break;

      case WsEventType.error:
        if (event is ErrorEvent) {
          Log.e('WebSocket: Server error - ${event.code}: ${event.message}');

          // Check for auth-related errors
          if (event.code.contains('AUTH') || event.code.contains('TOKEN')) {
            _updateConnectionState(WsConnectionState.authFailed);
            disconnect(isManual: true);
          }
        } else {
          Log.e('WebSocket: Received error event with invalid format');
        }
        break;
    }
  }

  /// Handle WebSocket error.
  void _onError(dynamic error) {
    Log.e('WebSocket: Connection error', error);
    _updateConnectionState(WsConnectionState.error);

    if (!_isManualDisconnect) {
      _scheduleReconnect();
    }
  }

  /// Handle WebSocket connection closed.
  void _onDone() {
    Log.d('WebSocket: Connection closed');

    if (!_isManualDisconnect) {
      _updateConnectionState(WsConnectionState.reconnecting);
      _scheduleReconnect();
    } else {
      _updateConnectionState(WsConnectionState.disconnected);
    }
  }

  // ===== HEARTBEAT =====

  /// Start heartbeat timer.
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      Duration(milliseconds: ApiConstant.wsHeartbeatInterval),
      (_) => _sendHeartbeat(),
    );
  }

  /// Send heartbeat ping.
  void _sendHeartbeat() {
    if (!isConnected) return;

    final ping = PingEvent();
    _sendRaw(ping.toJson());
  }

  // ===== RECONNECTION =====

  /// Schedule reconnection attempt with exponential backoff.
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    final maxAttempts = ApiConstant.wsMaxReconnectAttempts;
    if (maxAttempts > 0 && _reconnectAttempts >= maxAttempts) {
      Log.e('WebSocket: Max reconnect attempts reached');
      _updateConnectionState(WsConnectionState.error);
      return;
    }

    // Calculate delay with exponential backoff
    final delay = _calculateReconnectDelay();
    _reconnectAttempts++;

    Log.d(
      'WebSocket: Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
    );

    _reconnectTimer = Timer(delay, () async {
      _updateConnectionState(WsConnectionState.reconnecting);
      await connect();
    });
  }

  /// Calculate reconnect delay with exponential backoff.
  Duration _calculateReconnectDelay() {
    final baseMs = ApiConstant.wsReconnectDelayBase;
    final maxMs = ApiConstant.wsReconnectMaxDelay;

    // Exponential backoff: base * 2^attempts, capped at max
    final delayMs = (baseMs * (1 << _reconnectAttempts)).clamp(0, maxMs);

    return Duration(milliseconds: delayMs);
  }

  // ===== STATE MANAGEMENT =====

  /// Update connection state and notify listeners.
  void _updateConnectionState(WsConnectionState newState) {
    if (_connectionState == newState) return;

    _connectionState = newState;
    _connectionStateController.add(newState);
  }

  // ===== CLEANUP =====

  /// Dispose all resources.
  void dispose() {
    disconnect(isManual: true);
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _connectionStateController.close();
    _eventController.close();
  }
}
