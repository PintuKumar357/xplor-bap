// download_bloc.dart

import 'dart:async';

import 'package:dio/io.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xplor/features/multi_lang/domain/mappers/profile/profile_keys.dart';
import 'package:xplor/features/my_orders/domain/entities/add_document_to_wallet_entity.dart';
import 'package:xplor/utils/extensions/string_to_string.dart';

import '../../../../../const/local_storage/shared_preferences_helper.dart';
import '../../../../../core/dependency_injection.dart';
import '../../../../../utils/app_utils/app_utils.dart';
import '../../../domain/usecase/my_order_usecase.dart';
import 'certificate_event.dart';
import 'certificate_state.dart';

/// Bloc responsible for handling download operations.
class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  MyOrdersUseCase myOrdersUseCase;
  CertificateBloc({required this.myOrdersUseCase}) : super(DownloadInitial()) {
    on<CertificateInitial>(_onCertificateInitial);
    on<StartDownload>(_downloadCertificate);
    on<UpdateProgress>(_updateProgress);
    on<AddCertificateToWallet>(_onAddDocumentToWallet);
    on<MarkDocumentAddToWallet>(_onMarkDocumentToWallet);
  }

  FutureOr<void> _onCertificateInitial(
      CertificateInitial event, Emitter<CertificateState> emit) {
    emit(CertificateInitialState());
  }

  /// Handles the download of a certificate from a given URL.
  Future<void> _downloadCertificate(
      StartDownload event, Emitter<CertificateState> emit) async {
    Dio dio = Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
    };
    try {
      // Get the directory where the file will be saved
      var dir = await getExternalStorageDirectory();
      String filePath = '${dir?.path}/${event.fileName}';

      // Perform the download using Dio library
      await dio.download(
        event.url,
        filePath,
        onReceiveProgress: (received, total) {
          // Calculate download progress and emit UpdateProgress event
          if (total != -1) {
            var progress = double.parse((received / total).toStringAsFixed(2));
            add(UpdateProgress(progress));
          }
        },
      );

      // Notify download success with the file path
      emit(DownloadSuccess(filePath));
    } catch (e) {
      // Notify download failure with the error message
      emit(DownloadFailure(e.toString()));
    }
  }

  /// Updates the current download progress state.
  void _updateProgress(UpdateProgress event, Emitter<CertificateState> emit) {
    emit(DownloadInProgress(event.progress));
  }

  Future<FutureOr<void>> _onAddDocumentToWallet(
      AddCertificateToWallet event, Emitter<CertificateState> emit) async {
    emit(UploadDocumentLoadingState());

    List<String> tagList = [];
    if (event.ordersEntity?.itemDetails?.providerName != null &&
        event.ordersEntity?.itemDetails?.providerName != "") {
      tagList.add('${event.ordersEntity?.itemDetails?.providerName}');
    }
    tagList.add('certificate');

    AddDocumentToWalletEntity? entity = AddDocumentToWalletEntity(
        walletId:
            sl<SharedPreferencesHelper>().getString(PrefConstKeys.walletId),
        category: 'course',
        name:
            '${event.ordersEntity?.itemDetails?.descriptor?.name} - Certificate',
        fileUrl: event.url,
        tags: tagList);
    try {
      bool isSuccess = await myOrdersUseCase.uploadCertificateToWallet(entity);
      if (isSuccess) {
        add(MarkDocumentAddToWallet(event.ordersEntity?.id));
      } else {
        emit(
            DocumentUploadFailureState(ProfileKeys.unableToAdd.stringToString));
      }
    } catch (e) {
      emit(DocumentUploadFailureState(AppUtils.getErrorMessage(e.toString())));
    }
  }

  Future<FutureOr<void>> _onMarkDocumentToWallet(
      MarkDocumentAddToWallet event, Emitter<CertificateState> emit) async {
    try {
      await myOrdersUseCase.markAddToWallet(event.orderId!);
      emit(DocumentUploadSuccessState());
    } catch (e) {
      emit(DocumentUploadFailureState(AppUtils.getErrorMessage(e.toString())));
    }
  }
}
