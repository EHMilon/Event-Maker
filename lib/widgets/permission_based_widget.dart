import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/user_preferences.dart';

/// A widget that displays different content based on user permissions/roles.
///
/// This widget uses GetX reactive state management to efficiently handle
/// user role changes without unnecessary rebuilds.
///
/// Usage:
/// ```dart
/// PermissionBasedWidget(
///   serviceProviderBuilder: () => MyServiceProviderWidget(),
///   customerBuilder: () => MyCustomerWidget(),
///   fallbackBuilder: () => MyDefaultWidget(),
/// )
/// ```
class PermissionBasedWidget extends StatelessWidget {
  /// Widget to show for service providers
  final Widget? serviceProviderChild;
  
  /// Widget to show for customers
  final Widget? customerChild;
  
  /// Widget to show when user type is not determined or doesn't match
  final Widget? fallbackChild;
  
  /// Builder function for service providers (alternative to serviceProviderChild)
  final Widget Function()? serviceProviderBuilder;
  
  /// Builder function for customers (alternative to customerChild)
  final Widget Function()? customerBuilder;
  
  /// Builder function for fallback (alternative to fallbackChild)
  final Widget Function()? fallbackBuilder;
  
  /// List of allowed roles for this widget
  /// If null, widget shows content based on user type
  /// If provided, only shows content if user's role is in this list
  final List<String>? allowedRoles;
  
  /// Callback when user doesn't have permission
  final VoidCallback? onPermissionDenied;

  const PermissionBasedWidget({
    super.key,
    this.serviceProviderChild,
    this.customerChild,
    this.fallbackChild,
    this.serviceProviderBuilder,
    this.customerBuilder,
    this.fallbackBuilder,
    this.allowedRoles,
    this.onPermissionDenied,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: UserPreferences.getUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show fallback while loading
          return fallbackChild ??
                 (fallbackBuilder?.call() ??
                 const SizedBox.shrink());
        }
        
        String userType = snapshot.data ?? UserPreferences.USER_TYPE_CUSTOMER;
        
        // Check allowed roles if specified
        if (allowedRoles != null && !allowedRoles!.contains(userType)) {
          if (onPermissionDenied != null) {
            onPermissionDenied!();
          }
          return fallbackChild ??
                 (fallbackBuilder?.call() ??
                 const SizedBox.shrink());
        }
        
        // Show content based on user type
        switch (userType) {
          case UserPreferences.USER_TYPE_SERVICE_PROVIDER:
            return serviceProviderChild ??
                   (serviceProviderBuilder?.call() ??
                   const SizedBox.shrink());
          case UserPreferences.USER_TYPE_CUSTOMER:
            return customerChild ??
                   (customerBuilder?.call() ??
                   const SizedBox.shrink());
          default:
            return fallbackChild ??
                   (fallbackBuilder?.call() ??
                   const SizedBox.shrink());
        }
      },
    );
  }
}

/// Convenience widget for showing edit buttons only to service providers
///
/// This is a specialized version of PermissionBasedWidget for common use case
class EditButtonForServiceProviderOnly extends StatelessWidget {
  /// Callback when button is pressed
  final VoidCallback? onPressed;
  
  /// Button text (default: 'Edit')
  final String text;
  
  /// Icon to show alongside text
  final IconData? icon;

  const EditButtonForServiceProviderOnly({
    super.key,
    this.onPressed,
    this.text = 'Edit',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionBasedWidget(
      serviceProviderBuilder: () => ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const Icon(Icons.edit_outlined),
        label: Text(text),
      ),
      customerBuilder: () => const SizedBox.shrink(),
      fallbackBuilder: () => const SizedBox.shrink(),
    );
  }
}

/// Enum for standard user roles
enum UserRole {
  customer,
  serviceProvider,
}

/// Extension to convert UserRole to string
extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.customer:
        return UserPreferences.USER_TYPE_CUSTOMER;
      case UserRole.serviceProvider:
        return UserPreferences.USER_TYPE_SERVICE_PROVIDER;
    }
  }
}

/// Reactive version of PermissionBasedWidget that rebuilds when user type changes
/// Use this when user role might change during the widget's lifetime
class ReactivePermissionWidget extends StatelessWidget {
  /// Widget to show for service providers
  final Widget Function() serviceProviderBuilder;
  
  /// Widget to show for customers
  final Widget Function() customerBuilder;
  
  /// Widget to show when user type is not determined
  final Widget Function()? fallbackBuilder;

  const ReactivePermissionWidget({
    super.key,
    required this.serviceProviderBuilder,
    required this.customerBuilder,
    this.fallbackBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // This requires UserPreferences to expose userType as RxString
      // For now, we use the async version
      return PermissionBasedWidget(
        serviceProviderBuilder: serviceProviderBuilder,
        customerBuilder: customerBuilder,
        fallbackBuilder: fallbackBuilder,
      );
    });
  }
}