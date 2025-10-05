import 'package:dio/dio.dart';
import 'package:layout_tests/core/widgets/user_selection/domain/models/user_dto.dart';
import 'package:layout_tests/core/widgets/user_selection/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final Dio dio;

  UserRepositoryImpl(this.dio);

  @override
  Future<List<UserDTO>> fetchUsers() async {
    List<UserDTO> data = [];
    data.add(UserDTO(username: 'abner.teste', email: 'abner@gmail.com', name: 'Abner Rogerio', groupName: 'TI'));
    data.add(UserDTO(username: 'stephani.teste', email: 'stephani@gmail.com', name: 'Stephani Pine', groupName: 'TI'));
    data.add(UserDTO(username: 'romario', email: 'romario@gmail.com', name: 'Romario Ramires', groupName: 'COMPRAS'));
    data.add(UserDTO(username: 'yan', email: 'yan@gmail.com', name: 'yan', groupName: 'COMPRAS'));
    data.add(UserDTO(username: 'mario', email: 'mario@gmail.com', name: 'Mario da Silva', groupName: 'EXPORTAÇÃO'));
    data.add(UserDTO(username: 'vania', email: 'vania@gmail.com', name: 'Vania Matines', groupName: 'FISCAL'));
    data.add(UserDTO(username: 'rodrigo', email: 'rodrigo@gmail.com', name: 'Rodrigo Saverin', groupName: 'FISCAL'));
    data.add(UserDTO(username: 'carlos', email: 'carlos@gmail.com', name: 'Carlos da Silva Sauro', groupName: 'PPCP'));
    data.add(UserDTO(username: 'pedro', email: 'pedro@gmail.com', name: 'Pedro Garcia da Silva', groupName: 'PPCP'));
    data.add(UserDTO(username: 'ricardo', email: 'ricardo@gmail.com', name: 'Ricardo', groupName: 'EXPEDIÇÃO'));
    data.add(UserDTO(username: 'leticia', email: 'leticia@gmail.com', name: 'Leticia Garcia da Silva', groupName: 'LOGISTICA'));
    data.add(UserDTO(username: 'robson', email: 'robson@gmail.com', name: 'Robson Garcia da Silva', groupName: 'LOGISTICA'));

    return data;
    // final response = await dio.get('/users');
    // final List<dynamic> data = response.data;
    // return data.map((e) => UserDTO.fromJson(e)).toList();
  }
}
