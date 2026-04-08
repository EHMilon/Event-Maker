/// WebSocket Service for real-time chat communication.
///
/// Features:
/// - Connection lifecycle management
/// - Automatic reconnection with exponential backoff
/// - Heartbeat/ping-pong for connection health
/// - Event-based message handling
/// - Message sending and receiving

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/websocket_events.dart';

/// Callback type for incoming messages.
typedef MessageCallback = void Function(dynamic message);

/// Callback type for connection status changes.
typedef ConnectionCallback = void Function(bool isConnected);

/// WebSocket service for real-time chat.
class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  bool _isConnected = false;
  String? _currentChatId;
  String? _currentToken;
  int _reconnectAttempts = 0;
  
  final MessageCallback? onMessageReceived;
  final ConnectionCallback? onConnected;
  final ConnectionCallback? onDisconnected;
  final void Function(String error)? onError;

  WebSocketService({
    this.onMessageReceived,
    this.onConnected,
    this.onDisconnected,
    this.onError,
  });

  /// Check if currently connected
  bool get isConnected => _isConnected;

  /// Connect to WebSocket for a specific chat
  Future<bool> connect(String chatId, String token) async {
    if (_isConnected && _currentChatId == chatId) {
      return true;
    }

    // Disconnect existing connection if any
    await disconnect();

    _currentChatId = chatId;
    _currentToken = token;
    _reconnectAttempts = 0;

    return _establishConnection();
  }

  /// Establish WebSocket connection
  Future<bool> _establishConnection() async {
    if (_currentChatId == null || _currentToken == null) {
      onError?.call('Chat ID or token is missing');
      return false;
    }

    try {
      final wsUrl = ApiConstant.chatWebSocketUrl(_currentChatId!, _currentToken!);
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Wait for connection to be established
      await _channel!.ready.timeout(
        Duration(milliseconds: ApiConstant.wsConnectionTimeout),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _startHeartbeat();
      _listenToMessages();
      
      onConnected?.call(true);
      return true;
    } catch (e) {
      _isConnected = false;
      onError?.call('Failed to connect: $e');
      _scheduleReconnect();
      return false;
    }
  }

  /// Listen to incoming WebSocket messages
  void _listenToMessages() {
    _subscription = _channel?.stream.listen(
      (data) {
        try {
          final json = jsonDecode(data as String) as Map<String, dynamic>;
          
          // Handle different message types
          final type = json['type'] as String?;
          
          if (type == 'message' || type == 'message_received') {
            // Parse message received from server
            onMessageReceived?.call(json);
          } else if (type == 'ping') {
            // Respond to heartbeat ping
            _sendPong();
          } else if (type == 'error') {
            onError?.call(json['message'] as String? ?? 'Unknown error');
          }
        } catch (e) {
          // If not JSON, treat as plain text message
          onMessageReceived?.call(data);
        }
      },
      onError: (error) {
        _isConnected = false;
        onError?.call('WebSocket error: $error');
        _scheduleReconnect();
      },
      onDone: () {
        _isConnected = false;
        onDisconnected?.call(false);
        _scheduleReconnect();
      },
    );
  }

  /// Start heartbeat timer to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      Duration(milliseconds: ApiConstant.wsHeartbeatInterval),
      (_) => _sendPing(),
    );
  }

  /// Send ping to server
  void _sendPing() {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode({'type': 'ping'}));
      } catch (e) {
        // Silently handle send errors
      }
    }
  }

  /// Send pong response to server
  void _sendPong() {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode({'type': 'pong'}));
      } catch (e) {
        // Silently handle send errors
      }
    }
  }

  /// Send a message through WebSocket
  Future<bool> sendMessage(String content) async {
    if (!_isConnected || _channel == null) {
      onError?.call('Not connected to WebSocket');
      return false;
    }

    try {
      final message = {
        'content': content,
      };
      _channel!.sink.add(jsonEncode(message));
      return true;
    } catch (e) {
      onError?.call('Failed to send message: $e');
      return false;
    }
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator(bool isTyping) async {
    if (!_isConnected || _channel == null) return;

    try {
      final data = {
        'type': 'typing',
        'is_typing': isTyping,
      };
      _channel!.sink.add(jsonEncode(data));
    } catch (e) {
      // Silently handle send errors
    }
  }

  /// Schedule reconnection with exponential backoff
  void _scheduleReconnect() {
    if (ApiConstant.wsMaxReconnectAttempts > 0 &&
        _reconnectAttempts >= ApiConstant.wsMaxReconnectAttempts) {
      return;
    }

    _reconnectTimer?.cancel();
    
    final delay = _calculateBackoffDelay();
    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      if (_currentChatId != null && _currentToken != null) {
        _establishConnection();
      }
    });
  }

  /// Calculate exponential backoff delay
  int _calculateBackoffDelay() {
    final baseDelay = ApiConstant.wsReconnectDelayBase;
    final maxDelay = ApiConstant.wsReconnectMaxDelay;
    
    // Exponential backoff: base * 2^attempts
    int delay = baseDelay * (1 << _reconnectAttempts);
    
    // Add jitter to prevent thundering herd
    delay += (delay * 0.1 * (DateTime.now().millisecond % 10) / 10).toInt();
    
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    
    await _subscription?.cancel();
    await _channel?.sink.close();
    
    _isConnected = false;
    _currentChatId = null;
    _currentToken = null;
    _channel = null;
    
    onDisconnected?.call(false);
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
  }
}
