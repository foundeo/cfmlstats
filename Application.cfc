component {
	this.name = "cfmlstats";
	this.sessionManagement = false;

	public boolean function onRequestStart() {
		if (!isLocalhost(cgi.remote_addr)) {
			throw(message="Sorry localhost only");
			abort;
			return false;
		}
		return true;
	}
}