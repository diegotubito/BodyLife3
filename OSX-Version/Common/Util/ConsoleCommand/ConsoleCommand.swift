//
//  ConsoleCommand.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 16/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation

class MLConsoleCommand {
    static let instance = MLConsoleCommand()
    
    static func runProcess(name: String, arguments: [String], success: @escaping (Process) -> (), fail: @escaping (Error) -> Void) {
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: name)
        process.arguments = arguments
        process.terminationHandler = { (process) in
            success(process)
        }
        
        do {
            try process.run()
        } catch {
            fail(error)
        }
        
    }
    
    static func runProcess(name: String, arguments: [String]) -> Process? {
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: name)
        process.arguments = arguments
        
        do {
            try process.run()
        } catch {
            print("No se pudo ejecutar el proceso servidor")
            return nil
        }
        
        return process
    }
    
    static func checkTCP(port: in_port_t) -> (Bool, descr: String) {
        
        let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
        if socketFileDescriptor == -1 {
            return (false, "SocketCreationFailed, \(descriptionOfLastError())")
        }
        
        var addr = sockaddr_in()
        let sizeOfSockkAddr = MemoryLayout<sockaddr_in>.size
        addr.sin_len = __uint8_t(sizeOfSockkAddr)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(port) : port
        addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
        addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        var bind_addr = sockaddr()
        memcpy(&bind_addr, &addr, Int(sizeOfSockkAddr))
        
        if Darwin.bind(socketFileDescriptor, &bind_addr, socklen_t(sizeOfSockkAddr)) == -1 {
            let details = descriptionOfLastError()
            release(socket: socketFileDescriptor)
            return (false, "\(port), BindFailed, \(details)")
        }
        if listen(socketFileDescriptor, SOMAXCONN ) == -1 {
            let details = descriptionOfLastError()
            release(socket: socketFileDescriptor)
            return (false, "\(port), ListenFailed, \(details)")
        }
        release(socket: socketFileDescriptor)
        return (true, "\(port) is free for use")
    }
    
    private static func release(socket: Int32) {
        Darwin.shutdown(socket, SHUT_RDWR)
        close(socket)
    }
    
    private static func descriptionOfLastError() -> String {
        return String.init(cString: (UnsafePointer(strerror(errno))))
    }

}

