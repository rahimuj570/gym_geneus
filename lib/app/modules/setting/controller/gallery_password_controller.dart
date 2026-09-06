import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kenzeno/app/widgets/custom_snackbar.dart';

class GalleryPasswordController extends GetxController {
  final GetStorage _storage = GetStorage();
  static const String _storageKey = 'gallery_password';
  static const String defaultPin = '1234';

  var currentPassword = ''.obs;
  var newPassword = ''.obs;
  var confirmPassword = ''.obs;

  var isLoading = false.obs;
  var obscureCurrent = true.obs;
  var obscureNew = true.obs;
  var obscureConfirm = true.obs;

  String get savedPin => _storage.read<String>(_storageKey) ?? defaultPin;

  bool get pinsMatch =>
      newPassword.value.isNotEmpty &&
      newPassword.value == confirmPassword.value;

  bool get isValid =>
      currentPassword.value.isNotEmpty &&
      newPassword.value.isNotEmpty &&
      confirmPassword.value.isNotEmpty &&
      newPassword.value.length >= 4 &&
      pinsMatch;

  bool verifyPin(String enteredPin) {
    return enteredPin.trim() == savedPin;
  }

  Future<bool> changeGalleryPin() async {
    final cur = currentPassword.value.trim();
    final newP = newPassword.value.trim();
    final conf = confirmPassword.value.trim();

    if (cur.isEmpty) {
      CustomSnackbar.showError('Current PIN/Password cannot be empty');
      return false;
    }

    if (cur != savedPin) {
      CustomSnackbar.showError('Current PIN/Password is incorrect');
      return false;
    }

    if (newP.isEmpty) {
      CustomSnackbar.showError('New PIN/Password cannot be empty');
      return false;
    }

    if (newP.length < 4) {
      CustomSnackbar.showError('PIN/Password must be at least 4 digits');
      return false;
    }

    if (conf.isEmpty) {
      CustomSnackbar.showError('Please confirm your new PIN/Password');
      return false;
    }

    if (newP != conf) {
      CustomSnackbar.showError('New PIN/Passwords do not match');
      return false;
    }

    if (cur == newP) {
      CustomSnackbar.showError('New PIN cannot be the same as the current PIN');
      return false;
    }

    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      await _storage.write(_storageKey, newP);
      isLoading(false);

      CustomSnackbar.showSuccess('Gallery PIN updated successfully!');

      // Clear fields
      currentPassword.value = '';
      newPassword.value = '';
      confirmPassword.value = '';

      Get.back();
      return true;
    } catch (e) {
      isLoading(false);
      CustomSnackbar.showError('Failed to update PIN: $e');
      return false;
    }
  }
}
