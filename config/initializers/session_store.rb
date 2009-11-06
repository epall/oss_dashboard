# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rcos_monitor_session',
  :secret      => '52ad931880eaa709a2c68b4dea226431936fa7f430fb0afc25a8433f0244154b82a0192fa27540288453d8d55c3dd772c67712933db78a71f482cd3402e12606'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
