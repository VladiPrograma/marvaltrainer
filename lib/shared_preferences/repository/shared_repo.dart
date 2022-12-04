import 'package:creator/creator.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

Emitter<SharedPreferences?> _sharedFile = Emitter((ref, emit) async {
  emit(await SharedPreferences.getInstance());
}, keepAlive: true);
class SharedPreferencesRepository {

  SharedPreferences? getSharedPreferences(Ref ref){
    return ref.watch(_sharedFile.asyncData).data;
  }

  String? getString(Ref ref, String key){
    SharedPreferences? prefs = getSharedPreferences(ref);
    return prefs?.getString(key);
  }

  bool? getBool(Ref ref, String key){
    SharedPreferences? prefs = getSharedPreferences(ref);
    return prefs?.getBool(key);
  }

  void setInt(Ref ref, String key,  int value){
    SharedPreferences? prefs = ref.watch(_sharedFile.asyncData).data;
    prefs?.setInt(key, value);
  }

  void setBool(Ref ref, String key,  bool value){
    SharedPreferences? prefs = ref.watch(_sharedFile.asyncData).data;
    prefs?.setBool(key, value);
  }

  void setString(Ref ref, String key,  String value){
    SharedPreferences? prefs = ref.watch(_sharedFile.asyncData).data;
    prefs?.setString(key, value);
  }

  void setDouble(Ref ref, String key,  double value){
    SharedPreferences? prefs = ref.watch(_sharedFile.asyncData).data;
    prefs?.setDouble(key, value);
  }

  void setStringList(Ref ref, String key,  List<String> value){
    SharedPreferences? prefs = ref.watch(_sharedFile.asyncData).data;
    prefs?.setStringList(key, value);
  }
}