#
# Copyright (C) 2011 Red Hat, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301, USA.  A copy of the GNU General Public License is
# also available at http://www.gnu.org/copyleft/gpl.html.

FactoryGirl.define do

  factory :instance_key do
    sequence(:name) { |n| "instance_key#{n}" }
    pem "
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAm+Ri7uZz7iVTLLxtPiV2gLD37OOvovZ0VpWR3T7HK5NgxjlJssIjc8uKqPqY
EdXssF+ZKKypiQzFkMhowthkw1sGN5R3NBrIiRKR1mcVuE7iiRBFikBoF/CaaXP2LSNtMv4xkUXO
IdYfi+JFXIxjPHKpei3yuilZhoTdv8EH/oTsow7BZuK9R0XMc3a+U1btvoZ6CwRc0tTWmJyOkuh2
wVeQOTeaNbWzpuTWgJ5oda3CY7v+hbu1CT0AZ5vhSFWzDuvEEd4r15SQhH8X9Y7DnRhqDYDbBUdI
slQOFYi5KU5dJSzcjfSsA2u8UbcV24QsXOA3C9UofFNmJHG9hgQOgwIDAQABAoIBADdN9NMwKpyn
3TQXvOG5RKsvHSWLOPolWOyGr3LAHMSWylRIap7iRNWFtjFwhZZ+QDPqFlnZt2OJhmVw08mcH1M2
7aO2Jfv0LISEc/yOIaR7R968SQ9c/hDQKNeUbhdhZBIdH9Sb4R8b6aEkqtrEa0g8nWdc+amVlc8l
P84RWxat3wdZUH8c9inAD3UYrRFFA1ETZGt0fOr207qOfBSf0ytBgovlhmN2bfFjzKdpNluTXh62
vbgHkQMqf7pRU7ZjuuZiG/czV3a0aN4gg/SW7zFA+6+6R/0vmF1+vnsZ5YYUtDC4Fckc6wpms5oy
cpdBFuSYvs83Mph/SFXNai2aTTECgYEA3dvn4JVgTbOQgCc/hQwUlzGkmvXOlifdp/tfsh/3Hxj7
QOzZLuKPDiu8IYzqQtHC4of2N8vY9h/fHkLuQL6Tsfdu2S11SAk4vqfDjGDy8/BxZw1U5kcV+5MF
4dy5mHKKwQCuMybYSXZQcFUGSWsaVEDk9kzuD7j1P5JC4Z6M7CUCgYEAs+G6YUPfh1o1JD/4ZQN/
geM+K0o6VJSYMhmzcJ6XJQSwdMNwNaAhDzr4Gtqqrio6yzkzSNIYYPAREAFM0frBnZ6Oh+nEwZsu
nUTbaNGCpJ7MhqjQEDtNJDG/RoRtQeDpJ1MnwmJNbNe9h3qydqsrnBqqBamV+LmoWp4wARv7O4cC
gYEAwKM2JqptcWpuGOh7XgIMSu/e9nJiy7yX2UkKYbchs03UtB4zwmMURgCxnQwnSJesOVhG8VG9
9I/eAv+osm0H/2pSRJ8VC9R+AgXXZKe1rRxky08nHcAxlTymyeQG/xjN5CG8IEwlVzw1QiSBjfRC
a0/hvv8zYlF+GZHdItyxjkUCgYAoegOxfU9gKqlIlehz+nyHorXLkfFcNO+mXmglUFpcZxi5vXyT
ZIvr3G4VxNyhQjlmn2Ft4nC/52U/f7tkiJNmv1X9OVof4qZzlxn0FSjbmCwXpQbkkCOEoHkVChl3
uH9ebPTGZc5cTpOEV9SupUez4cAedBGeHVDHy06sATrgIwKBgQCdqFhrse+uhRacK1LAymvBsou5
5jj99IUCqIdgLelQ1yfI3Boj3qm8eZCBa8u7kbLx8F6zLCi6ry/k+JOwo3oa1pL9dfhXAnu/wwwt
1FGvv2zb+xR/fB/6+a4RMFsp9jO6lzTn/K1wsaZ6FNcdxB4V8ouveF0exhH/MEc0vWI47A==
-----END RSA PRIVATE KEY-----
"
  end

  factory :ec2_instance_key1, :parent => :instance_key do
    association :instance, :factory => :ec2_instance
    name "1_user"
  end

  factory :mock_instance_key, :parent => :instance_key do
    association :instance, :factory => :instance
  end

end
