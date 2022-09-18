import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_supercluster/src/layer/supercluster_layer_base.dart';
import 'package:supercluster/supercluster.dart';

import '../controller/marker_event.dart';
import '../controller/supercluster_controller.dart';
import '../options/animation_options.dart';
import 'cluster_data.dart';

class SuperclusterLayer extends SuperclusterLayerBase {
  /// Controller for replacing the markers. Note that this requires rebuilding
  /// the clusters and may take a second if you have many (~10000) markers.
  /// Consider using [SuperclusterMutableLayer] if you want to be able to
  /// add/remove [Marker]s quickly.
  @override
  final SuperclusterController? controller;

  const SuperclusterLayer({
    super.key,
    required super.builder,
    this.controller,
    super.initialMarkers = const [],
    super.onMarkerTap,
    super.minimumClusterSize,
    super.maxClusterRadius = 80,
    super.clusterDataExtractor,
    super.clusterWidgetSize = const Size(30, 30),
    super.clusterZoomAnimation = const AnimationOptions.animate(
      curve: Curves.linear,
      velocity: 1,
    ),
    super.popupOptions,
    super.rotate,
    super.rotateOrigin,
    super.rotateAlignment,
    super.anchor,
  });

  @override
  State<SuperclusterLayer> createState() => _SuperclusterLayerState();
}

class _SuperclusterLayerState
    extends SuperclusterLayerStateBase<SuperclusterLayer> {
  late Supercluster<Marker> _supercluster;

  @override
  void initializeClusterManager(List<Marker> markers) {
    _supercluster = Supercluster<Marker>(
      points: markers,
      getX: (m) => m.point.longitude,
      getY: (m) => m.point.latitude,
      minZoom: minZoom,
      maxZoom: maxZoom,
      extractClusterData: (marker) => ClusterData(
        marker,
        innerExtractor: widget.clusterDataExtractor,
      ),
      radius: widget.maxClusterRadius,
      minPoints: widget.minimumClusterSize,
    );
  }

  @override
  void onMarkerEvent(MarkerEvent markerEvent) {
    if (markerEvent is ReplaceAllMarkerEvent) {
      initializeClusterManager(markerEvent.markers);
    } else {
      throw 'Unsupported $MarkerEvent type: ${markerEvent.runtimeType}. Try using SuperclusterMutableLayer.';
    }

    setState(() {});
  }

  @override
  List<Marker> getAllMarkers() {
    return _supercluster.getLeaves().toList();
  }

  @override
  List<LayerElement<Marker>> search(
    double westLng,
    double southLat,
    double eastLng,
    double northLat,
    int zoom,
  ) =>
      _supercluster.search(westLng, southLat, eastLng, northLat, zoom);
}