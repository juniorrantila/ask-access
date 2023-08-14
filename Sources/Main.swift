import ArgumentParser
import Foundation
import SwiftSMTP

let askAccessSendFromKey = "ASK_ACCESS_SEND_FROM"
let askAccessSendToKey = "ASK_ACCESS_SEND_TO"
let tokenKey = "gmail-token"

let defaultAskAccessSendFrom = ProcessInfo.processInfo.environment[askAccessSendFromKey]
let defaultAskAccessSendTo = ProcessInfo.processInfo.environment[askAccessSendToKey]

@main struct AskAccess: ParsableCommand {
    private enum CodingKeys: CodingKey {
        case shouldResetToken 
        case projectName 
        case sendFrom
        case sendTo
    }

    @Flag(
        name: [.customShort("r"), .customLong("reset-token")],
        help: "Reset email token."
    )
    var shouldResetToken: Bool = false

    @Option(help: "Email to send from.")
    var sendFrom: String = defaultAskAccessSendFrom ?? ""

    @Option(
        help: "Email to send to.",
        completion: .list(["support@scalability.se"])
    )
    var sendTo: String = defaultAskAccessSendTo ?? ""

    @Argument(help: "The project name.")
    var projectName: String? = nil

    var keychain = Keychain(service: "local.ask-access")

    func checkProjectName() throws -> String? {
        guard let projectName = projectName else {
            if shouldResetToken {
                return nil
            }
            throw AppError(message: "expected project name")
        }
        if projectName.isEmpty {
            throw AppError(message: "expected project name")
        }
        return projectName
    }

    func checkSendFrom() throws -> Mail.User {
        guard !sendFrom.isEmpty else {
            throw AppError(message: "No email to send from, try setting '\(askAccessSendFromKey)' environment variable or seek '--help'")
        }
        return Mail.User(email: sendFrom)
    }

    func checkSendTo() throws -> Mail.User {
        guard !sendTo.isEmpty else {
            throw AppError(message: "No email to send to, try setting '\(askAccessSendToKey)' environment variable or seek '--help'")
        }
        return Mail.User(email: sendTo)
    }
}

extension AskAccess {
    mutating func run() throws {
        if shouldResetToken {
            doResetToken()
        }

        let token = try keychain[tokenKey] ?? {
            keychain[tokenKey] = requestToken()
            guard let token = keychain[tokenKey] else {
                throw AppError(message: "could not set token")
            }
            return token 
        }()

        guard let projectName = try checkProjectName() else {
            return
        }

        let sendFrom = try checkSendFrom()
        let sendTo = try checkSendTo()

        let subject = "SSH-access för \(projectName)"
        let content = "Tja,\n\nKan ni ge mig ssh-access till \(projectName)?"

        let smtp = SMTP(
            hostname: "smtp.gmail.com",
            email: sendFrom.email,
            password: token
        )

        let done = DispatchSemaphore(value: 0)
        smtp.send([Mail(
                from: sendFrom,
                to: [sendTo],
                subject: subject,
                text: content 
            )],
            progress: { (mail, error) in
                guard error == nil else {
                    fatalError(error.debugDescription)
                }
            },
            completion: { (sent, error) in
                guard error.isEmpty else {
                    fatalError("\(error[0])")
                }
                done.signal()
            }
        )
        done.wait()
    }

    mutating func doResetToken() {
        keychain[tokenKey] = nil
    }

    func requestToken() -> String? {
        signal(SIGINT) { _ in
            Terminal.showInput()
            AskAccess.exit()
        }

        print("gmail token: ", terminator: "")
        Terminal.hideInput()
        defer {
            Terminal.showInput()
            print()
        }
        return readLine(strippingNewline: true)
    }
}
