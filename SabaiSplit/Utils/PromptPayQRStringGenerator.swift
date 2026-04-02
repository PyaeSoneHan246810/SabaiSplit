//
//  PromptPayQRStringGenerator.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import Foundation

struct PromptPayQRStringGenerator {
    
    /// Generates PromptPay QR code string from phone number and amount
    /// - Parameters:
    ///   - phoneNumber: Thai phone number (10 digits, starting with 0)
    ///   - amount: Optional payment amount
    /// - Returns: EMV QR code string for PromptPay
    static func generateQRString(promptPayPhoneNumber: String, amount: Double?) -> String? {
        // Validate and format phone number
        guard let formattedPhone = formatPhoneNumber(promptPayPhoneNumber) else {
            return nil
        }
        
        // Build EMV QR code string
        var qrString = ""
        
        // Payload Format Indicator
        qrString += formatTag("00", "01")
        
        // Point of Initiation Method (12 = QR can be used multiple times)
        qrString += formatTag("01", "12")
        
        // Merchant Account Information
        var merchantInfo = ""
        merchantInfo += formatTag("00", "A000000677010111") // AID for PromptPay
        merchantInfo += formatTag("01", formattedPhone) // Phone number
        qrString += formatTag("29", merchantInfo)
        
        // Transaction Currency (764 = Thai Baht)
        qrString += formatTag("53", "764")
        
        // Transaction Amount (if provided)
        if let amount = amount, amount > 0 {
            let amountString = String(format: "%.2f", amount)
            qrString += formatTag("54", amountString)
        }
        
        // Country Code
        qrString += formatTag("58", "TH")
        
        // CRC Placeholder
        qrString += "6304"
        
        // Calculate CRC
        let crc = calculateCRC16(qrString)
        qrString += crc
        
        return qrString
    }
    
    /// Formats a tag with its value according to EMV specification
    /// - Parameters:
    ///   - tag: Two-digit tag identifier
    ///   - value: Tag value
    /// - Returns: Formatted tag string (tag + length + value)
    private static func formatTag(_ tag: String, _ value: String) -> String {
        let length = String(format: "%02d", value.count)
        return tag + length + value
    }
    
    /// Formats Thai phone number to PromptPay format (0066xxxxxxxxx)
    /// - Parameter phoneNumber: Input phone number
    /// - Returns: Formatted phone number or nil if invalid
    private static func formatPhoneNumber(_ phoneNumber: String) -> String? {
        // Remove all non-digit characters
        let digits = phoneNumber.filter { $0.isNumber }
        
        // Validate length
        guard digits.count == 10 else {
            return nil
        }
        
        // Must start with 0
        guard digits.hasPrefix("0") else {
            return nil
        }
        
        // Convert to international format (0066xxxxxxxxx)
        let withoutLeadingZero = String(digits.dropFirst())
        return "0066" + withoutLeadingZero
    }
    
    /// Calculates CRC-16/CCITT-FALSE checksum
    /// - Parameter data: Input string
    /// - Returns: 4-character hexadecimal CRC string
    private static func calculateCRC16(_ data: String) -> String {
        var crc: UInt16 = 0xFFFF
        
        for byte in data.utf8 {
            crc ^= UInt16(byte) << 8
            
            for _ in 0..<8 {
                if (crc & 0x8000) != 0 {
                    crc = (crc << 1) ^ 0x1021
                } else {
                    crc = crc << 1
                }
            }
        }
        
        return String(format: "%04X", crc & 0xFFFF)
    }
}
