import 'package:event_maker/data/models/service_model.dart';
import 'package:get/get.dart';

class ServicesController extends GetxController {
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt selectedPackageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      // Simulate network check (mock)
      // var connectivityResult = await (Connectivity().checkConnectivity());
      // if (connectivityResult == ConnectivityResult.none) {
      //   Get.snackbar('Error', 'No Internet Connection');
      //   isLoading.value = false;
      //   return;
      // }

      await Future.delayed(const Duration(seconds: 2)); // Simulate API delay

      services.value = [
        ServiceModel(
          id: '1',
          title: 'MIA LACHETTI MUSICAL CONCERT',
          description:
              'Clique Cabana, Desires, and Du Oro are teaming up to bring Space Miami resident Mia lachetti to the 5Church rooftop this Memorial Day Weekend.\n\nJoin us for a daytime affair featuring cutting-edge house music from one of Miami’s finest, supported by Atlanta’s top underground talent.',
          images: [
            'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=2070&auto=format&fit=crop',
          ],
          type: ServiceType.event,
          provider: ServiceProvider(
            name: 'Artcell',
            role: 'Organizer',
            imageUrl:
                'https://images.unsplash.com/photo-1598128558393-70ff21433be0?q=80&w=1978&auto=format&fit=crop',
            isVerified: true,
          ),
          location: '5Church Rooftop, Abu Dhabi',
          date: DateTime(2025, 12, 23, 15, 30),
          basePrice: 150,
          priceUnit: 'AED',
        ),
        ServiceModel(
          id: '2',
          title: 'Premium Home Cleaning',
          description:
              'Professional deep cleaning services for your home. Our experienced team uses eco-friendly products to ensure every corner of your house is spotless and sanitized.',
          images: [
            'https://images.unsplash.com/photo-1581578731548-c64695ce6958?q=80&w=1000&auto=format&fit=crop',
          ],
          type: ServiceType.cleaning,
          provider: ServiceProvider(
            name: 'Sparkle Cleaners',
            role: 'Service Provider',
            imageUrl:
                'https://images.unsplash.com/photo-1521791136064-7986c29598a5?q=80&w=1000&auto=format&fit=crop',
            isVerified: true,
          ),
          location: 'Main Street, Abu Dhabi',
          rating: 4.8,
          reviewCount: 85,
          packages: [
            ServicePackage(
              name: 'Basic',
              price: 100,
              features: [
                '2 hours cleaning',
                'Vacuuming & Mopping',
                'Bathroom cleaning',
              ],
            ),
            ServicePackage(
              name: 'Standard',
              price: 180,
              features: [
                '4 hours cleaning',
                'Kitchen deep clean',
                'Window cleaning',
                'Dusting',
              ],
            ),
            ServicePackage(
              name: 'Premium',
              price: 300,
              features: [
                'Full house deep clean',
                'Upholstery cleaning',
                'Disinfection service',
                'Laundry service',
              ],
            ),
          ],
        ),
        ServiceModel(
          id: '3',
          title: 'Professional Gym Trainer',
          description:
              'Get in shape with personalized fitness training. I specialize in weight loss, muscle gain, and overall functional fitness. Available for one-on-one sessions at your preferred location or gym.',
          images: [
            'https://images.unsplash.com/photo-1571019623518-f61db090f05e?q=80&w=1000&auto=format&fit=crop',
          ],
          type: ServiceType.training,
          provider: ServiceProvider(
            name: 'Alex Johnson',
            role: 'Fitness Coach',
            imageUrl:
                'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?q=80&w=1000&auto=format&fit=crop',
            isVerified: true,
          ),
          location: 'Khalidiya, Abu Dhabi',
          rating: 4.9,
          reviewCount: 42,
          basePrice: 200,
          priceUnit: 'AED',
        ),
      ];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPackage(int index) {
    selectedPackageIndex.value = index;
  }
}
