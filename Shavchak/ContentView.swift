//
//  ContentView.swift
//  Shavchak
//
//  Created by Eliya on 13/11/2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var soldiers: FetchedResults<SoldierEntity>
    
    var filteredSoldiers : FetchedResults<SoldierEntity> {
        if(searchText != ""){
            soldiers.nsPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)}
        else{
            soldiers.nsPredicate = nil
        }
        return soldiers
    }//filtered soldiers
    
    var sortedByLastEndDateSoldiers : FetchedResults<SoldierEntity>{
        let temp = soldiers
        temp.sortDescriptors.removeAll()
        temp.sortDescriptors.insert(SortDescriptor<SoldierEntity>(\.lastEndDate), at: 0)
        return temp
    }
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var teams: FetchedResults<TeamEntity>
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var missions: FetchedResults<MissionEntity>
     
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var missionNames: FetchedResults<MissionNameEntity>
    //
    //
    @State var pageNum : Int = 1
    
    @State var imgNames : [String] = ["icloud.circle","calendar.circle.fill","plus.circle","person.circle","gear.circle"]
    
    @State var dateChoosen : Date = Date()
    @State var startDateChoosen : Date = Date()
    @State var endDateChoosen : Date = Date()
    @State var teamChoosen : String = ""
    @State var missionNameChoosen : String = ""
    @State var missionSoldierNumChoosen : Int = 1
    
    @State var showAddMissionNameSheet : Bool = false
    @State var showEditMissionNameSheet : Bool = false
    @State var showAddSoldierSheet : Bool = false
    @State var showEditSoldierSheet : Bool = false
    @State var showAddTeamSheet : Bool = false
    @State var showEditTeamSheet : Bool = false
    
    @State var didAddMission : Bool = false
    @State var didDisplayRectangle : Bool = false
    
    @State var i : Int = 0
    
    @State var textInput : String = ""
    @State var searchText : String = ""
    
    @State var editSheetSoldierName : String = ""
    
    var body: some View {
        NavigationView{
            VStack{
                switch pageNum{
                case 0:
                    Text("0")
                    Spacer()
                case 1:
                    HStack{
                        DatePicker("Date", selection: $dateChoosen, displayedComponents: .date)
                        
                        Spacer()
                        
                        Button(action: {showAddMissionNameSheet.toggle()}, label: {Text("+")}).padding(.leading, 15)
                        
                        Spacer()
                    }.padding(.horizontal, 15)//date header
                    .sheet(isPresented: $showAddMissionNameSheet, content: {
                        VStack{
                            Text("Add Mission Name")
                            
                            TextField("New Mission Name", text: $textInput)
                                .autocorrectionDisabled()
                                .padding(.horizontal, 25)
                                .font(.system(size: 15))
                            Divider()
                                .padding(.horizontal, 25)
                            HStack{
                                Spacer()
                                Button("Save",action: {
                                    if textInput != "" {
                                        addMissionName(name: textInput)
                                        missionNameChoosen = textInput
                                        textInput = ""
                                    }
                                    showAddMissionNameSheet = false
                                })
                                Spacer()
                                Button("Cancle",role: .cancel,action: {
                                    textInput = ""
                                    showAddMissionNameSheet = false
                                })
                                Spacer()
                            }
                            .padding(.top, 5)
                        }
                        .presentationDetents([.fraction(0.2)])
                    })//show add mission name
                    
                     ScrollView(.horizontal){
                        HStack(spacing: 0){
                            ForEach(0..<25, id: \.self){index in
                                if(index == 0){
                                    Text("")
                                        .frame(width: 100, height: 100, alignment: .center)
                                        .background(Rectangle().fill(Color.clear))
                                } else {
                                    Text("\(index - 1):00")
                                        .frame(width: 60, height: 100, alignment: .center)
                                        .background(Rectangle().fill(Color.green))
                                }
                            }
                        }//mission table hour row
                         
                        ScrollView{
                            VStack{
                                ForEach(0..<missionNames.count, id: \.self){missionNameIndex in
                                    HStack(spacing: 0){
                                        Text("\(missionNames[missionNameIndex].name ?? "unknown")")//mission name rectangle
                                            .frame(width: 100, height: 100, alignment: .center)
                                            .background(Rectangle().fill(Color.blue))
                                        ForEach(0..<24, id: \.self){hourIndex in
                                            Text("\(missionNameIndex) \(hourIndex)")
                                                .frame(width: 60, height: 100, alignment: .center)
                                                .background(Rectangle().fill(getRectangleColor(dateChoosen: dateChoosen, missionNameIndex: missionNameIndex, hourIndex: hourIndex, missions: missions)))
                                        }
                                    }//table mission row
                                }
                            }//mission table
                            Text("\(missions.count)")
                        }
                    }
                case 2:
                    Text("Add Mission")
                    if(missionNames.count == 0 || teams.count == 0 || sortedByLastEndDateSoldiers.count == 0){
                        Text("You don't have missions or teams or soldiers")
                        Text("Please add those and than add a shift")
                    } else {
                        HStack{
                            Text("Choose Mission Type:")
                            Spacer()
                            Picker("בבקשה תבחר משימה",
                                   selection: $missionNameChoosen,
                                   content:{
                                ForEach(missionNames, id: \.self) {missionName in
                                    Text(missionName.name ?? "Unknown").tag(missionName.name ?? "Unknown")}
                            }).onAppear(perform: {if(missionNames.count != 0){missionNameChoosen = missionNames[0].name ?? "Unknown"}})
                        }.padding(15)//choose mission type
                        HStack{
                            Text("How Many Soldiers Do You Need?")
                            Spacer()
                            Picker("כמות לוחמים למשימה",
                                   selection: $missionSoldierNumChoosen,
                                   content:{
                                ForEach(1...sortedByLastEndDateSoldiers.count, id: \.self) {index in
                                    Text("\(index)").tag(index)}
                            })
                        }.padding(15)//choose soldier count
                        HStack{
                            Text("Choose Team:")
                            Spacer()
                            Picker("בבקשה תבחר צוות",
                                   selection: $teamChoosen,
                                   content:{
                                Text("מעורבב בין צוותים").tag("Mix")
                                ForEach(teams, id: \.self) {team in
                                    Text(team.name ?? "Unknown").tag(team.name ?? "Unknown")}
                            }).onAppear(perform: {if(teams.count != 0){teamChoosen = teams[0].name ?? "Unknown"}})
                        }.padding(15)//pick team
                        DatePicker("Start Date", selection: $startDateChoosen).padding(15)//start date picker
                        DatePicker("End Date", selection: $endDateChoosen).padding(15)//end date picker
                        Button(action: {
                            addMission(textInput: missionNameChoosen, start: startDateChoosen, end: endDateChoosen, numOfSoldiers: missionSoldierNumChoosen, teamChoosen: teamChoosen, sortedByLastEndDateSoldiers : sortedByLastEndDateSoldiers)
                        }, label: {Text("submit")})//add mission button
                    }
                    Spacer()
                case 3:
                    VStack{
                        HStack{
                            TextField("Search Bar", text: $searchText)
                                .padding(.horizontal, 15)
                                .autocorrectionDisabled()
                            Spacer()
                            Button(action: {}, label: {
                                Menu("+"){
                                    Button("חייל", action: {
                                        if(teams.count != 0){
                                            showAddSoldierSheet = true
                                            teamChoosen = teams[0].name ?? "Unknown"
                                        }
                                        else{
                                            showAddTeamSheet = true
                                        }
                                    })
                                    Button("צוות", action: {showAddTeamSheet = true})
                                }
                                .font(.system(size: 30))})//menu button
                            .padding(20)
                            .sheet(isPresented: $showAddSoldierSheet){
                                VStack{
                                    Text("הוסף לוחם")
                                    HStack{
                                        Text("תבחר צוות:")
                                            .padding(.leading, 25)
                                        Picker("בבקשה תבחר צוות",
                                               selection: $teamChoosen, content:{
                                            ForEach(teams) {team in
                                                Text(team.name ?? "Unknown").tag(team.name ?? "Unknown")}
                                        })
                                        Spacer()
                                    }
                                    TextField("שם הלוחם", text: $textInput)
                                        .autocorrectionDisabled()
                                        .padding(.horizontal, 25)
                                        .font(.system(size: 15))
                                    Divider()
                                        .padding(.horizontal, 25)
                                    HStack{
                                        Spacer()
                                        Button("הוסף",action: {
                                            if textInput != "" {
                                                addSoldier(name: textInput, teamName: teamChoosen)
                                                textInput = ""
                                            }
                                            showAddSoldierSheet = false
                                        })
                                        Spacer()
                                        Button("ביטול",role: .cancel,action: {
                                            textInput = ""
                                            showAddSoldierSheet = false
                                        })
                                        Spacer()
                                    }
                                    .padding(.top, 5)//Hstack
                                }
                                .presentationDetents([.fraction(0.2)])//Vstack
                            }//add soldier sheet
                            .sheet(isPresented: $showAddTeamSheet){
                                VStack{
                                    Spacer()
                                    Text("הוסף צוות")
                                    Spacer()
                                    TextField("שם הצוות", text: $textInput)
                                        .autocorrectionDisabled()
                                        .padding(.horizontal, 25)
                                        .font(.system(size: 15))
                                    Divider()
                                        .padding(.horizontal, 25)
                                    Spacer()
                                    HStack{
                                        Spacer()
                                        Button("הוסף",action: {
                                            if textInput != "" {
                                                addTeam(name: textInput)
                                                teamChoosen = textInput
                                                textInput = ""
                                            }
                                            showAddTeamSheet = false
                                        })
                                        Spacer()
                                        Button("ביטול",role: .cancel,action: {
                                            textInput = ""
                                            showAddTeamSheet = false
                                        })
                                        Spacer()
                                    }//Hstack
                                }//Vstack
                                .presentationDetents([.fraction(0.2)])
                                .padding(.bottom, 20)
                            }//add team sheet
                        }//header
                        Divider()
                        List{
                            ForEach(0..<filteredSoldiers.count, id: \.self){index in
                                Button(action: {
                                    teamChoosen = filteredSoldiers[index].teamName ?? "Unknown"
                                    editSheetSoldierName = filteredSoldiers[index].name ?? "Unknown"
                                    i = index
                                    showEditSoldierSheet = true}
                                       , label: {
                                    HStack{
                                        Text("\(filteredSoldiers[index].name ?? "unknown")")
                                        Spacer()
                                        Text("\(filteredSoldiers[index].teamName ?? "Unknown")")
                                    }//soldier row
                                })
                            }
                            .onDelete(perform: deleteSoldier)
                            .sheet(isPresented: $showEditSoldierSheet){
                                VStack{
                                    editSoldierSheet(editSheetSoldierName: $editSheetSoldierName)
                                    
                                    HStack{
                                        Text("תבחר צוות:")
                                            .padding(.leading, 25)
                                        
                                        Picker("בבקשה תבחר צוות",
                                               selection: $teamChoosen,
                                               content:{
                                            ForEach(0..<teams.count, id: \.self) {index in
                                                Text(teams[index].name ?? "Unknown").tag(teams[index].name ?? "Unknown")}
                                        })
                                        Spacer()
                                    }
                                    TextField("שם הלוחם", text: $textInput)
                                        .autocorrectionDisabled()
                                        .padding(.horizontal, 25)
                                        .font(.system(size: 15))
                                    Divider()
                                        .padding(.horizontal, 25)
                                    HStack{
                                        Spacer()
                                        Button("שמור",action: {
                                            if textInput != "" {
                                                editSoldier(index: i, name: textInput, teamName: teamChoosen)
                                            }else{
                                                editSoldier(index: i, name: filteredSoldiers[i].name ?? "Unknown", teamName: teamChoosen)}
                                            i = 0
                                            textInput = ""
                                            showEditSoldierSheet = false
                                        })
                                        Spacer()
                                        Button("ביטול",role: .cancel,action: {
                                            textInput = ""
                                            i = 0
                                            showEditSoldierSheet = false
                                        })
                                        Spacer()
                                    }
                                    .padding(.top, 5)//Hstack
                                }
                                .presentationDetents([.fraction(0.2)])//Vstack
                            }//edit soldier sheet
                        }//soldiers list
                        .listStyle(PlainListStyle())
                    }
                case 4:
                    List{
                        NavigationLink("צוותים", destination: {
                            List{
                                ForEach(0..<teams.count, id: \.self){ index in
                                    Button(action: {
                                        showEditTeamSheet.toggle()
                                        i = index
                                    },
                                           label: {
                                        Text("\(teams[index].name ?? "Unknown")")
                                    })
                                }
                                .onDelete(perform: deleteTeam)
                                .sheet(isPresented: $showEditTeamSheet, content: {
                                    VStack{
                                        Spacer()
                                        Text("עריכת צוות")
                                        Spacer()
                                        TextField("שם הצוות", text: $textInput)
                                            .autocorrectionDisabled()
                                            .padding(.horizontal, 25)
                                            .font(.system(size: 15))
                                        Divider()
                                            .padding(.horizontal, 25)
                                        Spacer()
                                        HStack{
                                            Spacer()
                                            Button("שמור",action: {
                                                if textInput != "" {
                                                    editTeam(index: i, name: textInput)
                                                    i = 0
                                                    textInput = ""
                                                }
                                                showEditTeamSheet = false
                                            })
                                            Spacer()
                                            Button("ביטול",role: .cancel,action: {
                                                textInput = ""
                                                showEditTeamSheet = false
                                            })
                                            Spacer()
                                        }//Hstack
                                    }//Vstack
                                    .presentationDetents([.fraction(0.2)])
                                    .padding(.bottom, 20)
                                })//edit team sheet
                            }//teams list
                            .listStyle(PlainListStyle())
                            .toolbar{
                                ToolbarItemGroup(placement: .navigationBarTrailing){
                                    Text("צוותים")
                                        .bold()
                                        .font(.system(size: 45))
                                }//header
                            }//toolbar
                            
                            Spacer()
                            buttomBar(pageNum: $pageNum, imgNames: $imgNames)
                        })//settings teams
                        NavigationLink("משימות", destination: {
                            List{
                                ForEach(0..<missionNames.count, id: \.self){ index in
                                    Button(action: {
                                        showEditMissionNameSheet.toggle()
                                        i = index
                                    },
                                           label: {
                                        Text(missionNames[index].name ?? "Unknown")
                                    })
                                }
                                .onDelete(perform: deleteMissionName)
                                .sheet(isPresented: $showEditMissionNameSheet, content: {
                                    VStack{
                                        Spacer()
                                        Text("עריכת משימה")
                                        Spacer()
                                        TextField("שם המשימה", text: $textInput)
                                            .autocorrectionDisabled()
                                            .padding(.horizontal, 25)
                                            .font(.system(size: 15))
                                        Divider()
                                            .padding(.horizontal, 25)
                                        Spacer()
                                        HStack{
                                            Spacer()
                                            Button("שמור",action: {
                                                if textInput != "" {
                                                    editMissionName(index: i, name: textInput)
                                                    i = 0
                                                    textInput = ""
                                                }
                                                showEditMissionNameSheet = false
                                            })
                                            Spacer()
                                            Button("ביטול",role: .cancel,action: {
                                                textInput = ""
                                                showEditMissionNameSheet = false
                                            })
                                            Spacer()
                                        }//Hstack
                                    }//Vstack
                                    .presentationDetents([.fraction(0.2)])
                                    .padding(.bottom, 20)
                                })//edit team sheet
                            }//teams list
                            .listStyle(PlainListStyle())
                            .toolbar{
                                ToolbarItemGroup(placement: .navigationBarTrailing){
                                    Text("משימות")
                                        .bold()
                                        .font(.system(size: 45))
                                }//header
                            }//toolbar
                            
                            Spacer()
                            buttomBar(pageNum: $pageNum, imgNames: $imgNames)
                        })//settings mission names
                        NavigationLink("missions", destination: {
                            List{
                                ForEach(0..<missions.count, id:\.self){index in
                                    Text(missions[index].name ?? "Unknown")
                                    Text("\(missions[index].start ?? Date())")
                                    Text("\(missions[index].end ?? Date())")
                                    Text("\(missions[index].soldiers!)")
                                }
                                .onDelete(perform: deleteMission)
                            }
                            Spacer()
                            buttomBar(pageNum: $pageNum, imgNames: $imgNames)
                        })
                    }
                    .listStyle(PlainListStyle())
                    .padding(.top , 20)
                    .toolbar{
                        ToolbarItemGroup(placement: .navigationBarTrailing){
                            Text("הגדרות")
                                .bold()
                                .font(.system(size: 45))
                        }//header
                    }//toolbar
                default:
                    Text("choose page")
                }
                buttomBar(pageNum: $pageNum, imgNames: $imgNames)
            }
        }
    }
    
    
    private func addTeam(name : String) {
        withAnimation {
            let newTeam = TeamEntity(context: viewContext)
            newTeam.name = name

            save()
        }
    }//add team
    
    private func deleteTeam(offsets : IndexSet) {
        withAnimation {
            offsets.map { teams[$0] }.forEach(viewContext.delete)
            
            save()
        }
    }//delete team
    
    private func editTeam(index : Int, name : String){
        withAnimation{
            updateAllSoldierTeams(oldTeamName: teams[index].name ?? "Unknown", newTeamName: name)
            teams[index].name = name
            
            save()
        }
    }//edit team
    
    private func addMissionName(name : String) {
        withAnimation {
            let newMissionName = MissionNameEntity(context: viewContext)
            newMissionName.name = name

            save()
        }
    }//add mission name
    
    private func deleteMissionName(offsets: IndexSet) {
        withAnimation {
            offsets.map { missionNames[$0] }.forEach(viewContext.delete)
            
            save()
        }
    }//delete mission name
    
    private func editMissionName(index : Int, name : String){
        withAnimation{
            updateAllMissionType(oldTeamName: missionNames[index].name ?? "Unknown", newTeamName: name)
            missionNames[index].name = name

            save()
        }
    }//edit mission name
    
    private func addMission(textInput : String, start : Date, end : Date, numOfSoldiers : Int, teamChoosen : String, sortedByLastEndDateSoldiers : FetchedResults<SoldierEntity>) {
        withAnimation {
            let newMission = MissionEntity(context: viewContext)
            newMission.name = textInput
            newMission.start = start
            newMission.end = end
            newMission.soldiers = ""
            
            #warning("add check if mission already exists for the mission name at the same time")
            var temp = 0
            var didAddSoldier = false
            
            for _ in 1...numOfSoldiers{
                print("#1")
                didAddSoldier = false
                while(!didAddSoldier){
                    print("#2")
                    while(isOnMission(soldier: sortedByLastEndDateSoldiers[temp], start: start, end: end, missions: missions)){
                        print("#3 \(sortedByLastEndDateSoldiers[temp].name ?? "Unknown")")
                        temp += 1
                        if(temp == sortedByLastEndDateSoldiers.count){
                            #warning("add pop up massage that says that the mission wasnt saved because there are no available soldiers")
                            print("return 1")
                            return
                        }//if there is no soldier available then return
                    }//while the soldier is on a mission when the mission is happening than go to the next soldier
                    
                    if(teamChoosen == "Mix" || teamChoosen == sortedByLastEndDateSoldiers[temp].teamName){
                        print("#4")
                        newMission.soldiers! += "\(sortedByLastEndDateSoldiers[temp].name ?? "Unknown") "
                        print(newMission.soldiers!)
                        sortedByLastEndDateSoldiers[temp].lastEndDate = end
                        temp += 1
                        didAddSoldier = true
                    }//if the soldier is in the selected team
                    else{
                        print("#5")
                        temp += 1
                        if(temp == sortedByLastEndDateSoldiers.count){
                            #warning("add pop up massage that says that the mission wasnt saved because there are no available soldiers")
                            return
                        }//if there is no soldier available then return
                    }
                }//while soldier wasn't added keep looking
            }//adding soldiers to the mission
            
            save()
            print("mission was saved")
        }
    }//add mission
    
    private func deleteMission(offsets: IndexSet) {
        withAnimation {
            offsets.map { missions[$0] }.forEach(viewContext.delete)
            
            save()
        }
    }//delete mission
    
    private func addSoldier(name : String, teamName : String) {
        withAnimation {
            let newSoldier = SoldierEntity(context: viewContext)
            newSoldier.name = name
            newSoldier.teamName = teamName
            newSoldier.lastEndDate = Date()
            
            save()
        }
    }//add soldier
    
    private func deleteSoldier(offsets: IndexSet) {
        withAnimation {
            offsets.map { soldiers[$0] }.forEach(viewContext.delete)
            
            save()
        }
    }// delete soldier
    
    private func editSoldier(index : Int, name : String, teamName : String){
        withAnimation{
            filteredSoldiers[index].name = name
            filteredSoldiers[index].teamName = teamName
            
            save()
        }
    }//edit soldier
    
    private func updateAllSoldierTeams(oldTeamName : String, newTeamName : String){
        withAnimation{
            for soldier in soldiers {
                if(soldier.teamName == oldTeamName){
                    soldier.teamName = newTeamName}
            }
            
            save()
        }
    }//update all soldier's teamName when edit team
    
    private func updateAllMissionType(oldTeamName : String, newTeamName : String){
        withAnimation{
            for mission in missions {
                if(mission.name == oldTeamName){
                    mission.name = newTeamName}
            }
            
            save()
        }
    }//update all soldier's teamName when edit team
    
    private func isOnMission(soldier : SoldierEntity, start : Date, end : Date, missions : FetchedResults<MissionEntity>) -> Bool {
        for mission in missions {
            if(mission.start ?? Date() > start &&
               mission.end ?? Date() < end &&
               ((mission.soldiers?.contains(soldier.name ?? "Unknown")) != nil) || (mission.soldiers?.contains(soldier.name ?? "Unknown")) == true){
                return true
            }
        }
        return false
    }//checks if a soldier is in a mission between 2 dates
    
    private func displayMission(missionNamesIndex : Int, hourIndex : Int, mission : MissionEntity, dateChoosen : Date) -> Bool {
        let missionStartHour = Calendar.current.component(.hour, from: mission.start!)
        let missionEndHour = Calendar.current.component(.hour, from: mission.end!)
        
        let dateChoosenYear = Calendar.current.component(.year, from: dateChoosen)
        let dateChoosenMonth = Calendar.current.component(.month, from: dateChoosen)
        let dateChoosenDay = Calendar.current.component(.day, from: dateChoosen)
        
        let missionStartYear = Calendar.current.component(.year, from: mission.start!)
        let missionStartMonth = Calendar.current.component(.month, from: mission.start!)
        let missionStartDay = Calendar.current.component(.day, from: mission.start!)
        
        let missionEndYear = Calendar.current.component(.year, from: mission.end!)
        let missionEndMonth = Calendar.current.component(.month, from: mission.end!)
        let missionEndDay = Calendar.current.component(.day, from: mission.end!)
        
        if((dateChoosenYear == missionStartYear && dateChoosenMonth == missionStartMonth && dateChoosenDay == missionStartDay &&
            dateChoosenYear == missionEndYear && dateChoosenMonth == missionEndMonth && dateChoosenDay == missionEndDay) && //check for dateChoosen if the date is right without hour
           ((mission.name ?? "Unknown") == (missionNames[missionNamesIndex].name ?? "Unknown"))){
            if((hourIndex >= missionStartHour && hourIndex <= missionEndHour)){
                return true
            }
            else{
                return false//if the mission starts and ends on the same day and the hour isnt right then return false
            }
        }//if the mission is on the same day
        
        if((dateChoosenYear >= missionStartYear && dateChoosenMonth >= missionStartMonth && dateChoosenDay >= missionStartDay &&
            dateChoosenYear <= missionEndYear && dateChoosenMonth <= missionEndMonth && dateChoosenDay <= missionEndDay) &&
           ((mission.name ?? "Unknown") == (missionNames[missionNamesIndex].name ?? "Unknown"))){
            if((dateChoosenYear == missionStartYear && dateChoosenMonth == missionStartMonth && dateChoosenDay == missionStartDay) &&
            hourIndex >= missionStartHour)
            {return true}//on the first day
            
            if(((dateChoosenYear == missionStartYear && dateChoosenMonth == missionStartMonth && dateChoosenDay > missionStartDay) ||
               (dateChoosenYear == missionStartYear && dateChoosenMonth > missionStartMonth && dateChoosenDay > missionStartDay) ||
               (dateChoosenYear > missionStartYear && dateChoosenMonth > missionStartMonth && dateChoosenDay > missionStartDay)) &&
               ((dateChoosenYear == missionEndYear && dateChoosenMonth == missionEndMonth && dateChoosenDay < missionEndDay) ||
                  (dateChoosenYear == missionEndYear && dateChoosenMonth < missionEndMonth && dateChoosenDay < missionEndDay) ||
                  (dateChoosenYear < missionEndYear && dateChoosenMonth < missionEndMonth && dateChoosenDay < missionEndDay)))
            {return true}//on the the between days
            
            if((dateChoosenYear == missionEndYear && dateChoosenMonth == missionEndMonth && dateChoosenDay == missionEndDay) &&
               hourIndex <= missionEndHour)
            {return true}//on the last day
            }//if the mission is on multipal days
        return false
    }//checks if to display a mission rectangle on the mission table or not
    
    private func getRectangleColor(dateChoosen : Date, missionNameIndex : Int, hourIndex : Int, missions : FetchedResults<MissionEntity>) -> Color{
        for mission in missions {
            if(displayMission(missionNamesIndex: missionNameIndex, hourIndex: hourIndex, mission: mission, dateChoosen: dateChoosen))
            {
                return Color.red
            }
        }
        
        return Color.clear
    }
    private func save(){
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }//save
}
