import 'package:get/get.dart';
import 'package:event_maker/models/service_model.dart';

class BookingController extends GetxController {
  // Default to current date
  final now = DateTime.now();
  
  final selectedDateIndex = 0.obs;
  final selectedTimeIndex = 0.obs;

  // Initialize with current month/year
  final selectedMonth = ''.obs;
  final selectedYear = ''.obs;
  final selectedDuration = ''.obs;
  final selectedLocation = ''.obs;
  final selectedAvailabilityId = 0.obs;

  // Service availability data from API (loaded dynamically)
  final RxList<ServiceAvailability> availabilities = <ServiceAvailability>[].obs;
  final RxBool isLoading = false.obs;
  
  // Computed available week days from all availabilities
  final RxSet<String> availableWeekDays = <String>{}.obs;
  
  // Available times for selected date (generated from start/end time)
  final RxList<String> availableTimes = <String>[].obs;
  
  // Available durations based on available time slots
  final RxList<String> availableDurations = <String>[].obs;
  
  // Available locations from availability addresses
  final RxList<String> availableLocations = <String>[].obs;

  // Month/Year lists - generated from current date
  final RxList<String> months = <String>[].obs;
  final RxList<String> years = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDateOptions();
  }

  /// Initialize month/year options from current date
  void _initializeDateOptions() {
    // Generate months from current month onwards
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final currentMonth = now.month; // 1-12
    final currentYear = now.year;
    
    // Months from current month to December
    final availableMonths = <String>[];
    for (int i = currentMonth - 1; i < 12; i++) {
      availableMonths.add(monthNames[i]);
    }
    months.assignAll(availableMonths);
    
    // Current month as default
    selectedMonth.value = monthNames[currentMonth - 1];
    
    // Generate years (current year + up to 5 years)
    final availableYears = <String>[];
    for (int i = 0; i < 5; i++) {
      availableYears.add((currentYear + i).toString());
    }
    years.assignAll(availableYears);
    selectedYear.value = currentYear.toString();
    
    // Initialize with empty defaults - will be populated when service is loaded
    selectedDuration.value = '';
    selectedLocation.value = '';
  }

  /// Load availability from service model
  void loadFromService(ServiceModel service) {
    if (service.availabilities.isEmpty) {
      // No availability - clear all options
      _clearAvailability();
      return;
    }

    availabilities.assignAll(service.availabilities);
    
    // Extract unique week days
    final weekDays = <String>{};
    for (final avail in service.availabilities) {
      weekDays.addAll(avail.weekDays);
    }
    availableWeekDays.value = weekDays;
    
    // Extract unique locations
    final locations = <String>{};
    for (final avail in service.availabilities) {
      if (avail.address.isNotEmpty) {
        locations.add(avail.address);
      }
    }
    availableLocations.assignAll(locations.toList()..sort());
    
    // Set default location
    if (availableLocations.isNotEmpty) {
      selectedLocation.value = availableLocations.first;
    }
    
    // Generate durations based on available time slots
    _generateDurations();
    
    // Set default times for first availability
    if (service.availabilities.isNotEmpty) {
      _updateAvailableTimes(service.availabilities.first);
    }
  }

  /// Clear availability data when none exists
  void _clearAvailability() {
    availabilities.clear();
    availableWeekDays.clear();
    availableLocations.clear();
    availableDurations.clear();
    availableTimes.clear();
    selectedLocation.value = '';
    selectedDuration.value = '';
  }

  /// Generate durations based on available time slot hours
  void _generateDurations() {
    final durations = <String>[];
    int maxHours = 0;
    
    // Find the maximum available hours from all availabilities
    for (final avail in availabilities) {
      final startParts = avail.startTime.split(':');
      final endParts = avail.endTime.split(':');
      
      if (startParts.length < 2 || endParts.length < 2) continue;
      
      final startHour = int.tryParse(startParts[0]) ?? 0;
      final endHour = int.tryParse(endParts[0]) ?? 0;
      final hours = endHour - startHour;
      
      if (hours > maxHours) {
        maxHours = hours;
      }
    }
    
    // Generate 1 Hour to N Hours based on max available
    for (int i = 1; i <= maxHours; i++) {
      durations.add(i == 1 ? '1 Hour' : '$i Hours');
    }
    
    // Add "Full Day" if available hours >= 8
    if (maxHours >= 8) {
      durations.add('Full Day');
    }
    
    availableDurations.assignAll(durations);
    
    // Default to 1 Hour if available
    if (durations.isNotEmpty) {
      selectedDuration.value = durations.first;
    }
  }

  /// Update available times based on selected availability slot
  void _updateAvailableTimes(ServiceAvailability availability) {
    final times = <String>[];
    final startParts = availability.startTime.split(':');
    final endParts = availability.endTime.split(':');
    
    if (startParts.length < 2 || endParts.length < 2) return;
    
    final startHour = int.tryParse(startParts[0]) ?? 9;
    final endHour = int.tryParse(endParts[0]) ?? 18;
    
    for (int hour = startHour; hour < endHour; hour++) {
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final period = hour >= 12 ? 'PM' : 'AM';
      times.add('${displayHour.toString().padLeft(2, '0')}:00 $period');
    }
    
    availableTimes.assignAll(times);
    if (times.isNotEmpty) {
      selectedTimeIndex.value = 0;
    }
  }

  /// Set selected location and update available times/duration
  void setSelectedLocation(String location) {
    selectedLocation.value = location;
    
    // Find availability with this address
    final avail = availabilities.firstWhereOrNull(
      (a) => a.address == location,
    );
    
    if (avail != null) {
      selectedAvailabilityId.value = avail.id;
      _updateAvailableTimes(avail);
      _generateDurations(); // Regenerate durations for this availability
    }
  }

  /// Check if a day is available
  bool isDayAvailable(String dayAbbrev) {
    if (availableWeekDays.isEmpty) return false;
    return availableWeekDays.contains(dayAbbrev);
  }

  void setSelectedDate(int index) => selectedDateIndex.value = index;
  void setSelectedTime(int index) => selectedTimeIndex.value = index;
  void setSelectedMonth(String month) => selectedMonth.value = month;
  void setSelectedYear(String year) => selectedYear.value = year;
  void setSelectedDuration(String duration) => selectedDuration.value = duration;

  // Backward-compatible getters for view compatibility
  List<String> get durations => availableDurations;
  List<String> get times => availableTimes;
  List<String> get locations => availableLocations;
}
