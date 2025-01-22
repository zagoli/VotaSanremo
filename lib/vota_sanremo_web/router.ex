defmodule VotaSanremoWeb.Router do
  use VotaSanremoWeb, :router

  import VotaSanremoWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VotaSanremoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug VotaSanremoWeb.SetLocalePlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  ## Logged in routes

  scope "/", VotaSanremoWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {VotaSanremoWeb.UserAuth, :ensure_authenticated},
        {VotaSanremoWeb.SetLocalePlug, :set_locale}
      ] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/users/profile/:user_id", UserProfileLive
      live "/vote", VoteLive, :show
      live "/vote/performance/:id", VoteLive, :vote
      live "/search/users", UserSearchLive, :search
      live "/juries/:jury_id/members/invite", UserSearchLive, :invite
      live "/juries/personal", PersonalJuriesLive
      live "/juries/new", NewJuryLive
      live "/juries/my_invites", MyInvitesLive
      live "/juries/:jury_id/members/invite/:user_id", JuryMembersLive
    end
  end

  ## Guest routes

  scope "/", VotaSanremoWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/leaderboard", LeaderboardLive

    live_session :user_and_guest_routes,
      on_mount: [
        {VotaSanremoWeb.UserAuth, :mount_current_user},
        {VotaSanremoWeb.SetLocalePlug, :set_locale}
      ] do
      live "/juries", JuriesLive
      live "/juries/:jury_id", JuryLive
      live "/juries/:jury_id/members", JuryMembersLive
    end
  end

  ## Authentication routes

  scope "/", VotaSanremoWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        {VotaSanremoWeb.UserAuth, :redirect_if_user_is_authenticated},
        {VotaSanremoWeb.SetLocalePlug, :set_locale}
      ] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", VotaSanremoWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [
        {VotaSanremoWeb.UserAuth, :mount_current_user},
        {VotaSanremoWeb.SetLocalePlug, :set_locale}
      ] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  ## Admin routes

  scope "/admin", VotaSanremoWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live_session :require_authenticated_admin,
      on_mount: [
        {VotaSanremoWeb.UserAuth, :ensure_authenticated},
        {VotaSanremoWeb.UserAuth, :ensure_admin},
        {VotaSanremoWeb.SetLocalePlug, :set_locale}
      ] do
      live "/editions", Admin.ManageEditionsLive

      live "/users", Admin.ManageUsersLive

      live "/performers", Admin.ManagePerformersLive, :index
      live "/performers/new", Admin.ManagePerformersLive, :new
      live "/performers/:id/edit", Admin.ManagePerformersLive, :edit

      live "/performance_types", Admin.ManagePerformanceTypesLive, :index
      live "/performance_types/new", Admin.ManagePerformanceTypesLive, :new
      live "/performance_types/:id/edit", Admin.ManagePerformanceTypesLive, :edit

      live "/evening/:id", Admin.ManageEveningLive
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:vota_sanremo, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VotaSanremoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
