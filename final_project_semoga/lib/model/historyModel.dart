import 'package:flutter/material.dart';

class HistoryModel {
  final int orderNumber;
  final String Driver;
  final String jenisKendaraan;
  final String nomorPlat;
  final String jenisBarang;
  final String alamatAsal;
  final String alamatTujuan;
  final DateTime tanggalPengantaran;
  final DateTime tanggalSampai;

  HistoryModel({
    required this.orderNumber,
    required this.Driver,
    required this.jenisKendaraan,
    required this.nomorPlat,
    required this.jenisBarang,
    required this.alamatAsal,
    required this.alamatTujuan,
    required this.tanggalPengantaran,
    required this.tanggalSampai,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      orderNumber: json['ekspedisi_Id'] ?? 0,
      Driver: json['nama_supir'] ?? '',
      jenisKendaraan: json['jenis_kendaraan'] ?? '',
      nomorPlat: json['nomor_plat'],
      jenisBarang: json['jenis_barang'] ?? '',
      alamatAsal: json['kota_asal'] ?? '',
      alamatTujuan: json['kota_tujuan'] ?? '',
      tanggalPengantaran: DateTime.parse(json['tanggal_pengiriman'] ?? ''),
      tanggalSampai: DateTime.parse(json['tanggal_sampai'] ?? ''),
    );
  }
}
