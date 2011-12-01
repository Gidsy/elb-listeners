install: 
	gem install clamp
	gem install aws-sdk
	cp elb_listeners.rb /usr/bin/elb_listeners
	chmod +x /usr/bin/elb_listeners
uninstall:
	rm /usr/bin/elb_listeners
