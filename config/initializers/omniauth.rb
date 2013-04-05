Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, '185877964860721', 'e345f2836e0f6e89d32e20ad87af7dae'
    provider :twitter, 'GW1ityUv8MFlLyDmVGdA', 'e2Pydt41is3ROit90avIR1bftc3FqHMkxr5bLC8U'
    provider :linked_in, '1ihgp8p3i0el', '0dMY7GrhM2CNeiPS'
    provider :google, 'CONSUMER_KEY', 'CONSUMER_SECRET'
end
