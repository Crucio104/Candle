import SwiftUI

public struct CategoryOrderView: View {
    @ObservedObject var store: BirthdayStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAddCategoryAlert = false
    @State private var newCategoryName = ""
    @State private var categoryToDelete: String? = nil
    @State private var showingDeleteAlert = false
    
    public init(store: BirthdayStore) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.orderedCategories) { item in
                        HStack(spacing: 12) {
                            Text(item.emoji)
                                .font(.system(size: 20))
                            
                            Text(item.name)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            if item.isCustom {
                                Text(store.tr(.customCategoryBadge))
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(store.accentPrimary)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(store.accentPrimary.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if item.isCustom {
                                Button(role: .destructive) {
                                    categoryToDelete = item.id
                                    showingDeleteAlert = true
                                } label: {
                                    Label(store.tr(.delete), systemImage: "trash")
                                }
                            }
                        }
                    }
                    .onMove { indices, newOffset in
                        store.reorderCategories(fromOffsets: indices, toOffset: newOffset)
                        CandleTheme.hapticSelection()
                    }
                } header: {
                    Text(store.tr(.reorderCategoriesTitle))
                } footer: {
                    Text(store.tr(.reorderCategoriesSubtitle))
                }
                
                Section {
                    Button {
                        CandleTheme.hapticSelection()
                        newCategoryName = ""
                        showingAddCategoryAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(store.accentPrimary)
                            Text(store.tr(.addCategoryBtn))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(store.accentPrimary)
                        }
                    }
                    
                    Button(role: .destructive) {
                        CandleTheme.hapticSelection()
                        withAnimation {
                            store.resetCategoryOrder()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 15))
                            Text(store.tr(.resetOrderBtn))
                                .font(.system(size: 15))
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle(store.tr(.reorderCategoriesTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.tr(.done)) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(store.accentPrimary)
                }
            }
            .alert(store.tr(.addCategoryBtn), isPresented: $showingAddCategoryAlert) {
                TextField(store.tr(.addCategoryPlaceholder), text: $newCategoryName)
                Button(store.tr(.addTagBtn)) {
                    let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        store.addCustomCategory(trimmed)
                        CandleTheme.hapticNotification(type: .success)
                    }
                }
                Button(store.tr(.cancel), role: .cancel) {}
            }
            .alert(
                categoryToDelete.map { store.tr(.deleteCategoryConfirm($0)) } ?? store.tr(.delete),
                isPresented: $showingDeleteAlert
            ) {
                Button(store.tr(.cancel), role: .cancel) {}
                Button(store.tr(.delete), role: .destructive) {
                    if let cat = categoryToDelete {
                        store.deleteCustomCategory(cat)
                        CandleTheme.hapticNotification(type: .success)
                    }
                }
            }
        }
    }
}
