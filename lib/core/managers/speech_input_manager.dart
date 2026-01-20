import 'dart:async';

/// Callback function type for stopping speech recognition
typedef StopListeningCallback = Future<void> Function();

/// Singleton manager to ensure only one microphone is listening at a time
/// across all FormTextFormField instances.
class SpeechInputManager {
  SpeechInputManager._internal();
  
  static final SpeechInputManager _instance = SpeechInputManager._internal();
  
  static SpeechInputManager get instance => _instance;

  /// Currently active listener's stop callback
  StopListeningCallback? _activeListenerStopCallback;
  
  /// Unique identifier for the currently active listener
  Object? _activeListenerId;

  /// Stream controller to notify listeners when they should stop
  final StreamController<Object?> _stopListeningController = 
      StreamController<Object?>.broadcast();
  
  /// Stream that emits when a listener should stop (excluding the emitter)
  Stream<Object?> get stopListeningStream => _stopListeningController.stream;

  /// Register a new listener and stop any previous one
  /// Returns true if registration was successful, false if another listener is active
  Future<bool> registerListener(
    Object listenerId,
    StopListeningCallback stopCallback,
  ) async {
    // If there's an active listener, stop it first
    if (_activeListenerId != null && _activeListenerId != listenerId) {
      await _stopActiveListener();
    }

    // Register this as the new active listener
    _activeListenerId = listenerId;
    _activeListenerStopCallback = stopCallback;
    
    // Notify all other listeners to stop (they'll check their own ID)
    _stopListeningController.add(listenerId);
    
    return true;
  }

  /// Unregister a listener (called when it stops naturally or is disposed)
  void unregisterListener(Object listenerId) {
    if (_activeListenerId == listenerId) {
      _activeListenerId = null;
      _activeListenerStopCallback = null;
    }
  }

  /// Stop the currently active listener
  Future<void> _stopActiveListener() async {
    if (_activeListenerStopCallback != null) {
      try {
        await _activeListenerStopCallback!();
      } catch (e) {
        // Ignore errors when stopping - listener might already be stopped
      }
      _activeListenerStopCallback = null;
    }
    _activeListenerId = null;
  }

  /// Check if a specific listener is currently active
  bool isActiveListener(Object listenerId) {
    return _activeListenerId == listenerId;
  }

  /// Force stop all listeners (useful for cleanup)
  Future<void> stopAllListeners() async {
    await _stopActiveListener();
    _stopListeningController.add(null);
  }

  /// Dispose the manager (should be called on app shutdown)
  void dispose() {
    _stopListeningController.close();
  }
}

