import 'backend_service.dart';

class LocationService {
  final BackendService backendService;

  LocationService(this.backendService);

  Future<List<Map<String, String>>> fetchLocations() async {
    return await backendService.fetchInventory();
  }
}
