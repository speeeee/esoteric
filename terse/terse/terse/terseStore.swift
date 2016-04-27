//
//  terseStore.swift
//  terse
//
//  Created by Spencer Sallay on 4/27/16.
//  Copyright © 2016 Spencer Sallay. All rights reserved.
//
import Foundation
//creates an instance of note store class
private let TerseStoreInstance = terseStore()

class terseStore{
    private var terses : [TCell]!
    
    class var sharedInstance : terseStore{
        return TerseStoreInstance; }
    
    init() { load(); }
    
    func getPrgm(index: Int) -> TCell {
        return terses[index]; }
    
    func addPrgm(ts : TCell){
        //   notes.append(note)
        terses.insert(ts, atIndex: 0); }
    
    func deletePrgm(n : Int) { terses.removeAtIndex(n) }
    
    func updatePrgm(tc : TCell, index: Int) {
        terses[index] = tc; }
    
    func getCount() -> Int { return terses.count; }
    /*func sort() {
        terses = terses.sort{
            $0.date.compare($1.date) == NSComparisonResult.OrderedDescending } }*/
    
    private func arciveFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let  documentsDirectory = paths.first!
        let path = (documentsDirectory as NSString).stringByAppendingPathComponent("TerseStore.plist")
        return path
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(terses, toFile: arciveFilePath()); }
    
    private func load() {
        let filePath = arciveFilePath()
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath) {
            terses = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! [TCell]; }
        else {//only happens first time
            terses = [];
            terses.append(TCell(title: "Test1", text: "1 2 + ."));
            terses.append(TCell(title: "Test2", text: "0 0 1 1 r"));
            terses.append(TCell(title: "Test3", text: "1 0.5 0.5 c 0 1 1 r"));
        }
        //sort()
    }
    
}