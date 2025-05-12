import SwiftUI

struct WeeklyChart: View {
    let values: [CGFloat]
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 24) {
            ForEach(0..<7, id: \.self) { index in
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(Color.toggleBackground)
                                .frame(height: geometry.size.height * values[index] / 100)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(.textSecondary),
                                    alignment: .top
                                )
                        }
                    }
                    
                    Text(days[index])
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.3)
                }
            }
        }
        .padding(.horizontal, 12)
    }
} 