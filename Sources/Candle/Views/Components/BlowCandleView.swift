import SwiftUI

public struct BlowCandleView: View {
    @ObservedObject var store: BirthdayStore
    let person: BirthdayPerson
    let onCelebrate: () -> Void
    
    @State private var isBlownOut: Bool = false
    
    public init(store: BirthdayStore, person: BirthdayPerson, onCelebrate: @escaping () -> Void) {
        self.store = store
        self.person = person
        self.onCelebrate = onCelebrate
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Interactive candle flame
                ZStack {
                    if isBlownOut {
                        Image(systemName: "smoke.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.gray.opacity(0.6))
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 28))
                            .foregroundColor(store.accentPrimary)
                            .shadow(color: store.accentPrimary.opacity(0.6), radius: 8, x: 0, y: 0)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(isBlownOut ? store.tr(.wishMadeTitle) : store.tr(.blowCandleTitle))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(isBlownOut ? store.tr(.wishMadeSubtitle) : store.tr(.blowCandleSubtitle(person.name)))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    blowOut()
                } label: {
                    Text(isBlownOut ? "✨ 🎉" : store.tr(.blowButton))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isBlownOut ? LinearGradient(colors: [.green], startPoint: .top, endPoint: .bottom) : store.accentGradient)
                        .clipShape(Capsule())
                        .shadow(color: store.accentPrimary.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .disabled(isBlownOut)
            }
            .padding(14)
            .background(CandleTheme.subCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(store.accentPrimary.opacity(isBlownOut ? 0.4 : 0.2), lineWidth: 1.2)
            )
        }
    }
    
    private func blowOut() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isBlownOut = true
        }
        onCelebrate()
        
        // Relight after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                isBlownOut = false
            }
        }
    }
}
