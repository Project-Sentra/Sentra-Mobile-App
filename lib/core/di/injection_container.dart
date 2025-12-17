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
import '../../features/parking/domain/usecases/get_parking_facilities_usecase.dart';
import '../../features/parking/domain/usecases/get_parking_slots_usecase.dart';
import '../../features/parking/domain/usecases/reserve_slot_usecase.dart';
import '../../features/parking/domain/usecases/search_facilities_usecase.dart';
import '../../features/parking/domain/usecases/get_recent_facilities_usecase.dart';
import '../../features/parking/presentation/bloc/parking_bloc.dart';
import '../../features/parking/presentation/bloc/slot_bloc.dart';

// Profile feature
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_user_reservations_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

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
  sl.registerLazySingleton(() => GetParkingFacilitiesUseCase(sl()));
  sl.registerLazySingleton(() => GetParkingSlotsUseCase(sl()));
  sl.registerLazySingleton(() => ReserveSlotUseCase(sl()));
  sl.registerLazySingleton(() => SearchFacilitiesUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentFacilitiesUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ParkingBloc(
      getParkingFacilitiesUseCase: sl(),
      searchFacilitiesUseCase: sl(),
      getRecentFacilitiesUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => SlotBloc(getParkingSlotsUseCase: sl(), reserveSlotUseCase: sl()),
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
  sl.registerLazySingleton(() => GetUserReservationsUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfileUseCase: sl(),
      getUserReservationsUseCase: sl(),
    ),
  );
}
