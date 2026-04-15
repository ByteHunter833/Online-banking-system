class AuthState {
  final bool isLoading;
  final bool isOtpVerified;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isOtpVerified = false,
    this.error,
  });

  AuthState copyWith({bool? isLoading, bool? isOtpVerified, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      error: error,
    );
  }
}
