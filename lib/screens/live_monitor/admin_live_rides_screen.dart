import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/admin_ride_model.dart';
import '../../services/admin_state_service.dart';

class AdminLiveRidesScreen extends StatefulWidget {
  const AdminLiveRidesScreen({super.key});

  @override
  State<AdminLiveRidesScreen> createState() => _AdminLiveRidesScreenState();
}

class _AdminLiveRidesScreenState extends State<AdminLiveRidesScreen> {
  GoogleMapController? _mapController;
  int _selectedRideIndex = 0;

  static const LatLng _defaultCenter = LatLng(12.9716, 77.5946); // Bangalore Center

  Set<Marker> _buildMarkers(List<AdminRideModel> activeRides) {
    final markers = <Marker>{};

    for (int i = 0; i < activeRides.length; i++) {
      final ride = activeRides[i];
      final isSelected = i == _selectedRideIndex;

      // Pickup Marker
      markers.add(
        Marker(
          markerId: MarkerId('${ride.id}_pickup'),
          position: LatLng(ride.pickupLat, ride.pickupLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: '${ride.id} - Pickup',
            snippet: ride.pickupAddress,
          ),
        ),
      );

      // Destination Marker
      markers.add(
        Marker(
          markerId: MarkerId('${ride.id}_dest'),
          position: LatLng(ride.destLat, ride.destLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: '${ride.id} - Destination',
            snippet: ride.destinationAddress,
          ),
        ),
      );

      // Captain Location Marker
      if (ride.captainLat != null && ride.captainLng != null) {
        markers.add(
          Marker(
            markerId: MarkerId('${ride.id}_captain'),
            position: LatLng(ride.captainLat!, ride.captainLng!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSelected ? BitmapDescriptor.hueCyan : BitmapDescriptor.hueAzure,
            ),
            infoWindow: InfoWindow(
              title: 'Captain: ${ride.captainName}',
              snippet: 'Status: ${ride.status.label} (${ride.vehicleType})',
            ),
          ),
        );
      }
    }

    return markers;
  }

  void _focusOnRide(AdminRideModel ride) {
    if (_mapController != null) {
      final targetLat = ride.captainLat ?? ride.pickupLat;
      final targetLng = ride.captainLng ?? ride.pickupLng;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(targetLat, targetLng),
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStateService(),
      builder: (context, _) {
        final activeRides = AdminStateService().liveRides;

        return Scaffold(
          body: Stack(
            children: [
              // Google Map View
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _defaultCenter,
                  zoom: 12.0,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (activeRides.isNotEmpty) {
                    _focusOnRide(activeRides[0]);
                  }
                },
                markers: _buildMarkers(activeRides),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),

              // Top Live Info Header
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AdminColors.successLight,
                          borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                        ),
                        child: const Icon(Icons.radar_rounded, color: AdminColors.success, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Live Platform Monitor',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${activeRides.length} active rides on road right now',
                              style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AdminDimensions.radiusFull),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: AdminColors.success, size: 8),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Active Rides Carousel
              if (activeRides.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: activeRides.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final ride = activeRides[index];
                            final isSelected = index == _selectedRideIndex;

                            return SizedBox(
                              width: 300,
                              child: Card(
                                color: Colors.white,
                                elevation: isSelected ? 6 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                                  side: BorderSide(
                                    color: isSelected ? AdminColors.primary : AdminColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _selectedRideIndex = index);
                                    _focusOnRide(ride);
                                  },
                                  borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  ride.id,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AdminColors.warningLight,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    ride.status.label,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: AdminColors.warning,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '₹${ride.fare.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AdminColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Captain: ${ride.captainName ?? "Unassigned"} (${ride.vehicleType})',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          'Passenger: ${ride.passengerName}',
                                          style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${ride.distanceKm} km • ~${ride.durationMins} mins',
                                              style: const TextStyle(fontSize: 11, color: AdminColors.textMuted),
                                            ),
                                            const Text(
                                              'Tap to locate',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AdminColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
