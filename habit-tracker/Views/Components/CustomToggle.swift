import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isOn.toggle()
            }
        }) {
            ZStack {
                Capsule()
                    .fill(isOn ? Color.accent : Color.toggleBackground)
                    .frame(width: 51, height: 31)
                
                HStack {
                    if !isOn {
                        Spacer()
                    }
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 27, height: 27)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 1.5)
                    
                    if isOn {
                        Spacer()
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
} 