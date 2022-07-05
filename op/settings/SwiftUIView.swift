//
//  SwiftUIView.swift
//  op
//
//  Created by Home on 1/7/2022.
//

import SwiftUI

struct SwiftUIView: View {
    //    var test1 = NEFilterSocketFlow()
        @State var nums: [String] = ["1", "2", "3", "4"]
        
        var body: some View {
            VStack {
                Text("Hello, world!")
                    .padding()
                
                List {
                    ForEach(nums, id: \.self) { num in
                        Text(num)
                    }
                    .onMove(perform: move)
                    .onDelete(perform: delete)
                }
            }
        }
        func move(from source: IndexSet, to destination: Int) {
            nums.move(fromOffsets: source, toOffset: destination)
        }
        func delete(at offsets: IndexSet) {
            nums.remove(atOffsets: offsets)
        }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
