class LoginRepository {
  LoginRepository();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      return {'token': 'TESTE', 'refresh_token': 'TESTE_TOKEN'};
    } on Exception catch (e) {
      throw e;
    }
  }
}
