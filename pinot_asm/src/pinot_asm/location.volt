module pinot_asm.location;

import watt.text.format;

struct Location {
	filename: string;
	line: i32;

	fn toString() string {
		return format("%s:%s", filename, line);
	}
}

// Return an error string.
fn errorString(loc: Location, msg: string) string {
	return format("%s:%s: %s", loc.filename, loc.line, msg);
}