import 'dart:async';

import 'package:dio/dio.dart';

import '../config/endpoint.dart';
import '../config/keys.dart';
import '../models/exceptions/api_exception.dart';
import '../models/team.dart';
import 'api_client.dart';

class TeamService {
  static final _client = ApiClient().init(baseUrl: Endpoint.baseUrl);

  Future<Team> create({required String name}) async {
    try {
      final data = {
        Keys.name: name
      };
      final response = await _client.post(Endpoint.teams, data: data);
      final teamData = response.data as Map<String, dynamic>;
      return Team.fromJson(teamData);
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<Team> getById({required int id}) async {
    try {
      final response = await _client.get(Endpoint.team.replaceAll(':id', id.toString()));
      final teamData = response.data as Map<String, dynamic>;
      return Team.fromJson(teamData);
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<Team> update({required int id, required Map<String, dynamic> data}) async {
    try {
      final response = await _client.patch(Endpoint.team.replaceAll(':id', id.toString()), data: data);
      final teamData = response.data as Map<String, dynamic>;
      return Team.fromJson(teamData);
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<String> inviteUser({required int id, required String email, required int role}) async {
    try {
      final data = {
        Keys.email: email,
        Keys.role: role
      };
      final response = await _client.post(Endpoint.inviteUser.replaceAll(':id', id.toString()), data: data);
      final responseData = response.data as Map<String, dynamic>;
      return responseData[Keys.message];
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<String> cancelInvite({required int id, required int teamInviteId}) async {
    try {
      final data = {
        Keys.teamInviteId: teamInviteId
      };
      final response = await _client.post(Endpoint.cancelInvite.replaceAll(':id', id.toString()), data: data);
      final responseData = response.data as Map<String, dynamic>;
      return responseData[Keys.message];
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<Map<String, dynamic>> acceptInvite({required String iid, required String uid, required String token}) async {
    try {
      final data = {
        Keys.iid: iid,
        Keys.uid: uid,
        Keys.token: token,
      };
      final response = await _client.post(Endpoint.acceptInvite, data: data);
      final responseData = response.data as Map<String, dynamic>;
      return responseData;
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }
}
