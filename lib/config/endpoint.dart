class Endpoint {
  Endpoint._();

  static const website = 'https://mterminal.app';
  static const app = 'me.mterminal.app';
  // static const app = 'localhost:50000';

  // static const baseUrl = 'http://0.0.0.0:8000';
  static const baseUrl = 'https://api.mterminal.app';

  //Auth
  static const authSignUp = '/auth/signup/';
  static const authLogIn = '/auth/token/';
  static const authLogOut = '/auth/logout/';
  static const authRefresh = '/auth/refresh/';
  static const authVerifyEmail = '/auth/verify_email/';
  static const authSendResetPasswordLink = '/auth/send_reset_password_link/';
  static const authResetPassword = '/auth/reset_password/';

  static const me = '/users/me/';
  static const changePassword = '/users/:id/change_password/';
  static const changeEmail = '/users/:id/change_email/';
  static const resendVerificationLink = '/users/:id/resend_verification_link/';
  static const roles = '/users/roles/';
  static const deleteAccount = '/users/:id/delete_account/';

  static const transactions = '/transactions/';
  static const transactionsCreateOrder = '/transactions/create_order/';
  static const transactionsCapture = '/transactions/:id/capture/';
  static const transactionsRestorePurchase = '/transactions/restore_purchase/';

  static const subscriptionPlans = '/subscription_plans/';

  static const devices = '/devices/';
  static const devicesUpdate = '/devices/create_or_update/';

  static const invoices = '/invoices/';

  static const tags = '/tags/';
  static const tag = '/tags/:id/';

  static const hosts = '/hosts/';
  static const host = '/hosts/:id/';

  static const secureShares = '/secure_shares/';
  static const secureShare = '/secure_shares/:id/';

  static const teams = '/teams/';
  static const team = '/teams/:id/';
  static const inviteUser = '/teams/:id/invite_user/';
  static const cancelInvite = '/teams/:id/cancel_invite/';
  static const acceptInvite = '/teams/join_team/';
}
