//
//  DataExporter.swift
//  expense
//
//  Created by Siddharth Patel on 8/18/25.
//

import Foundation
import SwiftUI
import CoreData
import CoreGraphics
import CoreText
import UIKit

class DataExporter: ObservableObject {
    enum ExportFormat: String, CaseIterable {
        case pdf = "PDF"
        case excel = "Excel (CSV)"
        
        var fileExtension: String {
            switch self {
            case .pdf: return "pdf"
            case .excel: return "csv"
            }
        }
    }
    
    // Export expenses and income to PDF
    func exportToPDF(expenses: [ExpenseItem], income: [IncomeItem], currencySymbol: String) -> URL? {
        let fileName = "expense_data_\(Date().timeIntervalSince1970).pdf"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            let pdfData = try createPDFContent(expenses: expenses, income: income, currencySymbol: currencySymbol)
            try pdfData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error creating PDF: \(error)")
            return nil
        }
    }
    
    // Export expenses and income to CSV (Excel compatible)
    func exportToCSV(expenses: [ExpenseItem], income: [IncomeItem], currencySymbol: String) -> URL? {
        let fileName = "expense_data_\(Date().timeIntervalSince1970).csv"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        // Helper function to properly escape CSV fields
        func escapeCSVField(_ field: String) -> String {
            if field.contains(",") || field.contains("\"") || field.contains("\n") {
                let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
                return "\"\(escaped)\""
            }
            return field
        }
        
        var csvContent = ""
        
        // Header
        csvContent += "Type,Date,Category,Amount,Notes\n"
        
        // Expenses
        for expense in expenses {
            let date = expense.date.formatted(date: .numeric, time: .shortened)
            let notes = expense.notes ?? ""
            let amount = String(format: "%.2f", expense.amount)
            csvContent += "Expense,\(escapeCSVField(date)),\(escapeCSVField(expense.categoryName)),\(escapeCSVField(currencySymbol + amount)),\(escapeCSVField(notes))\n"
        }
        
        // Income
        for incomeItem in income {
            let date = incomeItem.date.formatted(date: .numeric, time: .shortened)
            let notes = incomeItem.notes ?? ""
            let amount = String(format: "%.2f", incomeItem.amount)
            csvContent += "Income,\(escapeCSVField(date)),\(escapeCSVField(incomeItem.categoryName)),\(escapeCSVField(currencySymbol + amount)),\(escapeCSVField(notes))\n"
        }
        
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
    }
    
    private func createPDFContent(expenses: [ExpenseItem], income: [IncomeItem], currencySymbol: String) throws -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter size in points
        let topMargin: CGFloat = 72
        let leftMargin: CGFloat = 72
        let lineHeight: CGFloat = 20
        var yPosition: CGFloat = pageRect.height - topMargin
        
        // Debug: Print counts to verify data is being passed
        print("PDF Export - Expenses count: \(expenses.count), Income count: \(income.count)")
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let pdfData = pdfRenderer.pdfData { context in
            // Begin first page
            context.beginPage()
            
            // Set up text drawing function
            func drawText(_ text: String, at point: CGPoint, with font: UIFont, color: UIColor = .black) {
                // Ensure we're using the PDF context
                let cgContext = context.cgContext
                UIGraphicsPushContext(cgContext)
                defer { UIGraphicsPopContext() }
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color
                ]
                
                // Use NSString's draw method - this should work in PDF context
                let nsString = text as NSString
                nsString.draw(at: point, withAttributes: attributes)
            }
            
            // Helper to check if new page is needed
            func checkPageBreak(requiredHeight: CGFloat) {
                if yPosition - requiredHeight < topMargin {
                    context.beginPage()
                    yPosition = pageRect.height - topMargin
                }
            }
            
            // Title
            checkPageBreak(requiredHeight: 50)
            let title = "Expense Report"
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            drawText(title, at: CGPoint(x: leftMargin, y: yPosition), with: titleFont)
            yPosition -= 40
            
            // Date
            checkPageBreak(requiredHeight: 30)
            let dateString = Date().formatted(date: .long, time: .shortened)
            let dateFont = UIFont.systemFont(ofSize: 12)
            drawText(dateString, at: CGPoint(x: leftMargin, y: yPosition), with: dateFont, color: .gray)
            yPosition -= 40
            
            // Summary
            checkPageBreak(requiredHeight: 40)
            let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
            let totalIncome = income.reduce(0) { $0 + $1.amount }
            let netAmount = totalIncome - totalExpenses
            drawText("Total Expenses: \(currencySymbol)\(String(format: "%.2f", totalExpenses))", at: CGPoint(x: leftMargin, y: yPosition), with: dateFont)
            yPosition -= 20
            drawText("Total Income: \(currencySymbol)\(String(format: "%.2f", totalIncome))", at: CGPoint(x: leftMargin, y: yPosition), with: dateFont)
            yPosition -= 20
            drawText("Net Amount: \(currencySymbol)\(String(format: "%.2f", netAmount))", at: CGPoint(x: leftMargin, y: yPosition), with: UIFont.boldSystemFont(ofSize: 14), color: netAmount >= 0 ? .systemGreen : .systemRed)
            yPosition -= 40
            
            // Income Section (first)
            checkPageBreak(requiredHeight: 50)
            let sectionFont = UIFont.boldSystemFont(ofSize: 18)
            drawText("Income (\(income.count))", at: CGPoint(x: leftMargin, y: yPosition), with: sectionFont)
            yPosition -= 30
            
            if income.isEmpty {
                drawText("No income recorded.", at: CGPoint(x: leftMargin, y: yPosition), with: UIFont.systemFont(ofSize: 12), color: .gray)
                yPosition -= lineHeight
            } else {
                for incomeItem in income {
                    checkPageBreak(requiredHeight: lineHeight)
                    let incomeText = "• \(incomeItem.categoryName): \(currencySymbol)\(String(format: "%.2f", incomeItem.amount)) - \(incomeItem.date.formatted(date: .numeric, time: .shortened))"
                    let textFont = UIFont.systemFont(ofSize: 12)
                    drawText(incomeText, at: CGPoint(x: leftMargin, y: yPosition), with: textFont)
                    yPosition -= lineHeight
                    
                    // Add notes if available
                    if let notes = incomeItem.notes, !notes.isEmpty {
                        checkPageBreak(requiredHeight: lineHeight)
                        let notesText = "  Note: \(notes)"
                        drawText(notesText, at: CGPoint(x: leftMargin + 20, y: yPosition), with: UIFont.systemFont(ofSize: 10), color: .gray)
                        yPosition -= lineHeight
                    }
                }
            }
            
            yPosition -= 20
            
            // Expenses Section (last)
            checkPageBreak(requiredHeight: 50)
            drawText("Expenses (\(expenses.count))", at: CGPoint(x: leftMargin, y: yPosition), with: sectionFont)
            yPosition -= 30
            
            if expenses.isEmpty {
                drawText("No expenses recorded.", at: CGPoint(x: leftMargin, y: yPosition), with: UIFont.systemFont(ofSize: 12), color: .gray)
                yPosition -= lineHeight
            } else {
                for expense in expenses {
                    checkPageBreak(requiredHeight: lineHeight)
                    let expenseText = "• \(expense.categoryName): \(currencySymbol)\(String(format: "%.2f", expense.amount)) - \(expense.date.formatted(date: .numeric, time: .shortened))"
                    let textFont = UIFont.systemFont(ofSize: 12)
                    drawText(expenseText, at: CGPoint(x: leftMargin, y: yPosition), with: textFont)
                    yPosition -= lineHeight
                    
                    // Add notes if available
                    if let notes = expense.notes, !notes.isEmpty {
                        checkPageBreak(requiredHeight: lineHeight)
                        let notesText = "  Note: \(notes)"
                        drawText(notesText, at: CGPoint(x: leftMargin + 20, y: yPosition), with: UIFont.systemFont(ofSize: 10), color: .gray)
                        yPosition -= lineHeight
                    }
                }
            }
        }
        
        return pdfData
    }
}
