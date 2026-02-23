import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth feature
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Parking feature
import '../../features/parking/data/datasources/parking_remote_datasource.dart';
import '../../features/parking/data/repositories/parking_repository_impl.dart';
import '../../features/parking/domain/repositories/parking_repository.dart';
import '../../features/parking/domain/usecases/get_parking_locations_usecase.dart';
import '../../features/parking/domain/usecases/get_spots_by_location_usecase.dart';
import '../../features/parking/domain/usecases/search_facilities_usecase.dart';
import '../../features/parking/presentation/bloc/parking_bloc.dart';

// Profile feature
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_user_reservations_usecase.dart'
    show GetUserSessionsUseCase;
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

// Vehicles feature
import '../../features/vehicles/data/datasources/vehicle_remote_data_source.dart';
import '../../features/vehicles/data/datasources/vehicle_remote_data_source_impl.dart';
import '../../features/vehicles/data/repositories/vehicle_repository_impl.dart';
import '../../features/vehicles/domain/repositories/vehicle_repository.dart';
import '../../features/vehicles/domain/usecases/get_vehicles_usecase.dart';
import '../../features/vehicles/domain/usecases/add_vehicle_usecase.dart';
import '../../features/vehicles/domain/usecases/update_vehicle_usecase.dart';
import '../../features/vehicles/domain/usecases/delete_vehicle_usecase.dart';
import '../../features/vehicles/presentation/bloc/vehicle_bloc.dart';

// Payment feature
import '../../features/payment/data/datasources/payment_remote_data_source.dart';
import '../../features/payment/data/datasources/payment_remote_data_source_impl.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/get_payment_methods_usecase.dart';
import '../../features/payment/domain/usecases/add_payment_method_usecase.dart';
import '../../features/payment/domain/usecases/delete_payment_method_usecase.dart';
import '../../features/payment/domain/usecases/process_payment_usecase.dart';
import '../../features/payment/domain/usecases/get_payment_history_usecase.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';

// History feature
import '../../features/history/data/datasources/history_remote_data_source.dart';
import '../../features/history/data/datasources/history_remote_data_source_impl.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/get_parking_history_usecase.dart';
import '../../features/history/domain/usecases/get_active_sessions_usecase.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';

// Booking feature
import '../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../features/booking/data/datasources/booking_remote_datasource_impl.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/usecases/create_reservation_usecase.dart';
import '../../features/booking/domain/usecases/get_user_reservations_usecase.dart';
import '../../features/booking/domain/usecases/get_active_reservations_usecase.dart';
import '../../features/booking/domain/usecases/cancel_reservation_usecase.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ========== Auth Feature ==========
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithAppleUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      signInWithAppleUseCase: sl(),
    ),
  );

  // ========== Parking Feature ==========
  // Data sources
  sl.registerLazySingleton<ParkingRemoteDataSource>(
    () => ParkingRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ParkingRepository>(
    () => ParkingRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetParkingLocationsUseCase(sl()));
  sl.registerLazySingleton(() => GetSpotsByLocationUseCase(sl()));
  sl.registerLazySingleton(() => SearchSpotsUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ParkingBloc(
      getParkingLocationsUseCase: sl(),
      getSpotsByLocationUseCase: sl(),
      searchSpotsUseCase: sl(),
    ),
  );

  // ========== Profile Feature ==========
  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetUserSessionsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfileUseCase: sl(),
      getUserSessionsUseCase: sl(),
      updateProfileUseCase: sl(),
    ),
  );

  // ========== Vehicles Feature ==========
  // Data sources
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetVehiclesUseCase(sl()));
  sl.registerLazySingleton(() => AddVehicleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVehicleUseCase(sl()));
  sl.registerLazySingleton(() => DeleteVehicleUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => VehicleBloc(
      getVehiclesUseCase: sl(),
      addVehicleUseCase: sl(),
      updateVehicleUseCase: sl(),
      deleteVehicleUseCase: sl(),
    ),
  );

  // ========== Payment Feature ==========
  // Data sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPaymentMethodsUseCase(sl()));
  sl.registerLazySingleton(() => AddPaymentMethodUseCase(sl()));
  sl.registerLazySingleton(() => DeletePaymentMethodUseCase(sl()));
  sl.registerLazySingleton(() => ProcessPaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentHistoryUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => PaymentBloc(
      getPaymentMethodsUseCase: sl(),
      addPaymentMethodUseCase: sl(),
      deletePaymentMethodUseCase: sl(),
      processPaymentUseCase: sl(),
      getPaymentHistoryUseCase: sl(),
    ),
  );

  // ========== History Feature ==========
  // Data sources
  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetParkingHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveSessionsUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => HistoryBloc(
      getParkingHistoryUseCase: sl(),
      getActiveSessionsUseCase: sl(),
    ),
  );

  // ========== Booking Feature ==========
  // Data sources
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateReservationUseCase(sl()));
  sl.registerLazySingleton(() => GetUserReservationsUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveReservationsUseCase(sl()));
  sl.registerLazySingleton(() => CancelReservationUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => BookingBloc(
      createReservationUseCase: sl(),
      getUserReservationsUseCase: sl(),
      getActiveReservationsUseCase: sl(),
      cancelReservationUseCase: sl(),
    ),
  );
}
