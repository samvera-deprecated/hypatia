# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_hypatia-hh_session',
  :secret      => 'aeb5c9290cce26bd9c0a5c8934e4c9c267790e7c1229be7afdc2f9989387348d40d1bbe83d192bb2b62bb04e66c0710de0d4deb94262ac70aa347f62ea5e9dc5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
