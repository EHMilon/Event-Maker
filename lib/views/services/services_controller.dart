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

  void loadServices() async {
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
                'https://images.unsplash.com/photo-1598128558393-70ff21433be0?q=80&w=1978&auto=format&fit=crop', // Logo placeholder
            isVerified: true,
          ),
          location: '5Church Rooftop, Abu Dhabi',
          date: DateTime(2025, 12, 23, 15, 30),
          basePrice: 120,
          priceUnit: 'AED',
        ),
        ServiceModel(
          id: '2',
          title: 'Elite Event Photography',
          description:
              'Capturing your special moments with artistic precision and creativity. We specialize in event photography with over 8 years of experience documenting weddings, corporate events, and celebrations.',
          images: [
            'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=1000&auto=format&fit=crop',
          ],
          type: ServiceType.photography,
          provider: ServiceProvider(
            name: 'John Doe Photography',
            role: 'Service Provider',
            imageUrl:
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000&auto=format&fit=crop',
            isVerified: true,
          ),
          location: 'Airport Rd - Al Manhal - W14 02 - Abu Dhabi',
          rating: 4.5,
          reviewCount: 124,
          packages: [
            ServicePackage(
              name: 'Basic',
              price: 120,
              features: [
                '4 hours coverage',
                '100 edited photos',
                'Online gallery',
                'Basic retouching',
              ],
            ),
            ServicePackage(
              name: 'Standard',
              price: 299,
              features: [
                '6 hours coverage',
                '200 edited photos',
                'Online gallery',
                'Advanced retouching',
                'Photo album',
              ],
            ),
            ServicePackage(
              name: 'Premium',
              price: 499,
              features: [
                '8 hours coverage',
                '300 edited photos',
                'Online gallery',
                'Advanced retouching',
                'Photo album',
                'Video highlights',
              ],
            ),
          ],
        ),
        ServiceModel(
          id: '3',
          title: 'Professional Bengali Cooking Training',
          description:
              'Master the art of Bengali cuisine in this immersive, hands-on training program. You will explore the balance of the "Panch Phoron" (five-spice blend) and learn authentic techniques for signature dishes like Shorshe Ilish, Kosha Mangsho, and delicate Mishti Doi.',
          images: [
            'https://images.unsplash.com/photo-1556910638-6cdac31d44dc?q=80&w=1000&auto=format&fit=crop',
          ],
          type: ServiceType.training,
          provider: ServiceProvider(
            name: 'Keka Ferdousi',
            role: 'Chef',
            imageUrl:
                'https://images.unsplash.com/photo-1583394293214-28ded15ee548?q=80&w=1000&auto=format&fit=crop',
          ),
          location: 'Airport Rd - Al Manhal - W14 02 - Abu Dhabi',
          date: DateTime(2025, 12, 23, 15, 30),
          basePrice: 120,
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
