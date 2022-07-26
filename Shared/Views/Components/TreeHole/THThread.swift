import SwiftUI

struct THThread: View {
    @EnvironmentObject var dataModel: THDataModel
    @State var hole: THHole
    @State var endReached = false
    
    func fetchMoreFloors() async {
        guard let token = dataModel.token else {
            return
        }
        
        do {
            let lastStorey = hole.floors.last!.storey // floors will never be empty, as it contains `firstFloor`
            let newFloors = try await THloadFloors(token: token, holeId: hole.id, startFloor: lastStorey + 1)
            
            endReached = newFloors.isEmpty
            hole.floors.append(contentsOf: newFloors)
            
        } catch {
            print("DANXI-DEBUG: load new floors failed")
        }
    }
    
    
    var body: some View {
        List {
            Section {
                ForEach(hole.floors) { floor in
                    THFloorView(floor: floor)
                        .task {
                            if floor == hole.floors.last {
                                await fetchMoreFloors()
                            }
                        }
                }
            } header: {
                TagListSimple(tags: hole.tags)
            } footer: {
                if !endReached {
                    HStack() {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .textCase(nil)
        }
#if !os(watchOS)
        .listStyle(.grouped)
#endif
        .navigationTitle("#\(String(hole.id))")
        .navigationBarTitleDisplayMode(.inline)
    }
}




struct THThread_Previews: PreviewProvider {
    static let tag = THTag(id: 1, temperature: 1, name: "Tag")
    
    static let floor = THFloor(
        id: 1234567, holeId: 123456,
        iso8601UpdateTime: "2022-04-14T08:23:12.761042+08:00",
        iso8601CreateTime: "2022-04-14T08:23:12.761042+08:00", updateTime: Date.now,
        createTime: Date.now,
        like: 12,
        liked: true,
        storey: 5,
        content: """
        Hello, **Dear** readers!
        
        We can make text *italic*, ***bold italic***, or ~~striked through~~.
        
        You can even create [links](https://www.twitter.com/twannl) that actually work.
        
        Or use `Monospace` to mimic `Text("inline code")`.
        
        """,
        posterName: "Dax")
    
    static let hole = THHole(
        id: 123456,
        divisionId: 1,
        view: 15,
        reply: 13,
        iso8601UpdateTime: "2022-04-14T08:23:12.761042+08:00",
        iso8601CreateTime: "2022-04-14T08:23:12.761042+08:00",
        updateTime: Date.now, createTime: Date.now,
        tags: Array(repeating: tag, count: 5),
        firstFloor: floor, lastFloor: floor, floors: Array(repeating: floor, count: 10))
    
    static var dataModel = THDataModel()
    
    static var previews: some View {
        Group {
            NavigationView {
                THThread(hole: hole)
            }
            
            NavigationView {
                THThread(hole: hole)
                    .preferredColorScheme(.dark)
            }
        }
        .environmentObject(dataModel)
    }
}
