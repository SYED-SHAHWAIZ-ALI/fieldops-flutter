import 'client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients();
  Future<Client?> getClientById(String id);
  Future<List<Client>> searchClients(String query);
}
