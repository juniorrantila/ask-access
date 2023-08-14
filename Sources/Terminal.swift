#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("unknown OS")
#endif

struct Terminal {

    private init() {}

    public static func hideInput() {
        var oldt = termios()
        tcgetattr(STDIN_FILENO, &oldt)
        var newt = oldt
        newt.c_lflag &= ~tcflag_t(ECHO)
        tcsetattr(STDIN_FILENO, TCSANOW, &newt)
    }

    public static func showInput() {
        var oldt = termios()
        tcgetattr(STDIN_FILENO, &oldt)
        var newt = oldt
        newt.c_lflag |= tcflag_t(ECHO)
        tcsetattr(STDIN_FILENO, TCSANOW, &newt)
    }
}

