import 'package:layout_tests/core/widgets/user_selection/domain/models/user_dto.dart';

abstract class UserRepository {
  Future<List<UserDTO>> fetchUsers();
}
