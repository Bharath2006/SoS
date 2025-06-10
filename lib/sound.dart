import 'package:just_audio/just_audio.dart';

class SOSService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> triggerSOSAlert() async {
    await _audioPlayer.setAsset("assets/ala.wav");
    await _audioPlayer.play();
    print('SOS alarm triggered');
  }

  Future<void> stopSOSAlert() async {
    await _audioPlayer.stop();
    print('SOS alarm stopped');
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
