//
//  TimelineNode.swift
//  Rules Horror
//
//  Created by Tensorcraft on 13/05/2025.
//  Updated: 13/05/2025
//

import SwiftUI
import UIKit


struct TimelineNode: Identifiable {
    let id: String
    var label: String
    var position: CGPoint
    var size: CGSize
    var unlocked: Bool
}

struct TimelineConnection: Identifiable {
    let id = UUID()
    let from: String
    let to:   String
    let path: [CGPoint]
}


private extension String {
    func nodeWidth(font: UIFont = .systemFont(ofSize: 16)) -> CGFloat {
        let raw = (self as NSString).size(withAttributes: [.font: font]).width
        return max(70, raw + 32)
    }
}

class TimelineViewModel: ObservableObject {

    private let hSpacing: CGFloat = 40
    private let vSpacing: CGFloat = 40
    private let nodeHeight: CGFloat = 70
    
    @Published var nodes: [TimelineNode] = []
    @Published var connections: [TimelineConnection] = []

    var contentWidth: CGFloat  { (nodes.map { $0.position.x + $0.size.width / 2 }.max() ?? 0) + 100 }
    var contentHeight: CGFloat { (nodes.map { $0.position.y + $0.size.height / 2 }.max() ?? 0) + 100 }
    
    func generateTimeline(from novel: Novel) {

        var visited = Set<String>()
        var levelMap: [Int: [String]] = [:]
        var queue: [(name: String, depth: Int)] = [(novel.entry, 0)]
        visited.insert(novel.entry)
        
        while !queue.isEmpty {
            let (name, depth) = queue.removeFirst()
            levelMap[depth, default: []].append(name)
            
            guard let chapter = novel.chapters.first(where: { $0.name == name }) else { continue }
            for message in chapter.messages where message.type == MessageTypeOptions {
                for next in message.routes ?? [] where !visited.contains(next) {
                    visited.insert(next)
                    queue.append((next, depth + 1))
                }
            }
        }

        struct Temp {
            let id: String; let label: String
            let depth: Int; let row: Int
            let unlocked: Bool; let width: CGFloat
        }
        var temps: [Temp] = []
        for (depth, names) in levelMap {
            for (row, name) in names.enumerated() {
                let chapter = novel.chapters.first { $0.name == name }!
                let unlocked = chapter.unlocked == true
                let label = unlocked ? chapter.name : "???"
                let width = label.nodeWidth()
                temps.append(Temp(id: name, label: label, depth: depth, row: row, unlocked: unlocked, width: width))
            }
        }
        
        var colMax: [Int: CGFloat] = [:]
        temps.forEach { colMax[$0.depth] = max(colMax[$0.depth] ?? 0, $0.width) }
        
        var xOffsets: [Int: CGFloat] = [:]    
        var runningX: CGFloat = 0
        let maxDepth = colMax.keys.max() ?? 0
        for d in 0...maxDepth {
            if d > 0 { runningX += (colMax[d-1] ?? 0) + hSpacing }
            xOffsets[d] = runningX
        }
        
        nodes = temps.map { t in
            let x = (xOffsets[t.depth] ?? 0) + t.width / 2
            let y = CGFloat(t.row) * (nodeHeight + vSpacing) + nodeHeight / 2
            return TimelineNode(id: t.id,
                                label: t.label,
                                position: CGPoint(x: x, y: y),
                                size: CGSize(width: t.width, height: nodeHeight),
                                unlocked: t.unlocked)
        }
        
        connections = []
        for chapter in novel.chapters {
            for msg in chapter.messages where msg.type == MessageTypeOptions {
                for route in msg.routes ?? [] {
                    guard
                        let fromNode = nodes.first(where: { $0.id == chapter.name }),
                        let toNode   = nodes.first(where: { $0.id == route })
                    else { continue }
                    
                    let midX = (fromNode.position.x + toNode.position.x) / 2
                    connections.append(
                        TimelineConnection(
                            from: chapter.name,
                            to: route,
                            path: [
                                fromNode.position,
                                CGPoint(x: midX, y: toNode.position.y),
                                toNode.position
                            ]
                        )
                    )
                }
            }
        }
    }
    
    func unlockChapter(_ id: String) {
        guard let idx = nodes.firstIndex(where: { $0.id == id }) else { return }
        nodes[idx].unlocked = true
        nodes[idx].label = id
    }
}


struct TimelineGraph: View {
    @ObservedObject var viewModel: TimelineViewModel
    var onNodeTap: (String) -> Void
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack {
                ForEach(viewModel.connections) { link in
                    Path { p in
                        p.move(to: link.path[0])
                        p.addLine(to: link.path[1])
                        p.addLine(to: link.path[2])
                    }
                    .stroke(Color.white, lineWidth: 2)
                }
                
                ForEach(viewModel.nodes) { node in
                    Button {
                        if node.unlocked { onNodeTap(node.id) }
                    } label: {
                        Text(node.label)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal, 16)
                            .frame(width: node.size.width, height: node.size.height)
                            .background {
                                if node.unlocked {
                                    Image("titlebar")
                                        .resizable()
                                        .frame(height: node.size.height)
                                        .scaledToFill()
                                        .clipped()
                                } else {
                                    Color(red: 0.1, green: 0.1, blue: 0.1)
                                }
                            }
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .position(node.position)
                }
            }
            .frame(width: viewModel.contentWidth,
                   height: viewModel.contentHeight)
            .padding()
        }
    }
}
