def noteDecoder(noteDecode): 
    print("Note Decoder");
    notes=["c","c#","d","d#","e","f","f#","g","g#","a","a#","b"];
    #number = 1575;
    number = noteDecode;
    dr = int(number/128);
    oc = int((number-128*dr)/16);
    nt = int(number-128*dr-16*oc);
    # print("note: ",nt);
    # print("octave: ",oc);
    # print("duration: ",dr);
    # print(notes[nt]+str(oc)+","+str(dr));
    return notes[nt]+str(oc),dr
    # 594
    #   Duration   Octave Note
    # 0 0100       101    0010
    # 1575
    #   Duration   Octave Note
    # 0 1100       010    0111
    # 1618
    #   Duration   Octave Note
    # 0 1100       101    0010

def voiceSplitter(vNo,vDu,vWave):
    #v1=["a4",1,"b6",2,"c3",4];
    #vNo=["a4","b6","c3"];
    #vdu=[1,2,4];
    vSplitted=[];
    vSplitWave =[];
    for i in range(0,len(vNo)):
        print ("nota",vNo[i]);
        print("duration",vDu[i]);
        for j in range(0,vDu[i]):
            vSplitted.append(vNo[i]);
            if j == vDu[i]-1:
                vSplitWave.append(vWave-1);
            else:
                vSplitWave.append(vWave);
    return(vSplitted,vSplitWave);      

def translateNotes(vSource):
    vNo = [];
    vDu = [];
    for noteCoded in vSource:
        noteDec,durDec= noteDecoder(noteCoded);
        vNo.append(noteDec);
        vDu.append(durDec);
    return vNo,vDu

def sliceNotes(vSource,vWave):
    #vSource=[594,594,594,596,596,1618,587,592,587,585,331,336];
    vNo,vDu = translateNotes(vSource);
    vSplitted,vSpliWave = voiceSplitter(vNo,vDu,vWave);
    return vSplitted,vSpliWave

def formatAssembler(vSplitted,vSplitWave):
    chunk_size = 10
    vToPrint=[]
    vWaveToPrint=[]
    print("voiceNotes:");
    for i in range(0, len(vSplitted), chunk_size):
        vToPrint.append(vSplitted[i:i + chunk_size]);
    for line in vToPrint:
        lineAssemblerAscii= "  .ascii "
        for element in line:
            lineAssemblerAscii += element + ","
        print (lineAssemblerAscii[:-1]);   
    print("voiceWaves:");  
    for i in range(0, len(vSplitWave), chunk_size):
        vWaveToPrint.append(vSplitWave[i:i + chunk_size]);
    for line in vWaveToPrint:
        lineAssemblerByte= "  .byte "
        for element in line:
            lineAssemblerByte += str(element) + ","
        print (lineAssemblerByte[:-1]);  

def main():
    #print(noteDecoder());
    #voiceSplitter();
    v1Wave=17;
    v1Source=[594,594,594,596,596,1618,587,592,587,585,331,336,
             1097,583,585,585,585,587,587,1609,585,331,337,594,594,593,
             1618,594,596,594,592,587,1616,587,585,331,336,841,327,1607];
    vSplitNotes,vSplitWave=sliceNotes(v1Source,v1Wave);
    formatAssembler(vSplitNotes,vSplitWave);
    v2Wave=65;
    v2Source=[583,585,583,583,327,329,1611,583,585,578,578,578,
              196,198,583,326,578,326,327,329,327,329,326,578,583,
              1606,582,322,324,582,587,329,327,1606,583,327,329,587,331,329,
              329,328,1609,578,834,324,322,327,585,1602];
    v3Wave=33;
    v3Source=[567,566,567,304,306,308,310,1591,567,311,310,567,
              306,304,299,308,304,171,176,306,291,551,306,308,
              310,308,310,306,295,297,299,304,1586,562,567,310,315,311,
              308,313,297,1586,567,560,311,309,308,309,306,308,
              1577,299,295,306,310,311,304,562,546,1575];
    

if __name__ == "__main__":
    main()