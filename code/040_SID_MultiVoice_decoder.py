def octaveNotes(note):
    #notesFreqOct7=[35114,37202,39415,41758,44241,46872,
    #               49659,52612,55741,59055,62567,66287];
    noteFreqOct7 ={
                "C":35114,
                "C#":37202,
                "D":39415,
                "D#":41758,
                "E":44241,
                "F": 46872,
                "F#": 49659,
                "G": 52612,
                "G#": 55741,
                "A": 59055,
                "A#": 62567,
                "B": 66287,
                "S": 0, #the silence
                }

    if len(note) == 2:
        noteLetter = note[0];
        noteOctave = note[-1];
    elif len(note) ==3:
        noteLetter = note[:2];
        noteOctave = note[-1];
    intOctave=int(noteOctave);
    if intOctave == 7:
        freqNote = noteFreqOct7[noteLetter.upper()];
    elif intOctave >=0 and intOctave <7:
        freqNote = noteFreqOct7[noteLetter.upper()];
        for i in range(0,7-intOctave):
            freqNote = int(freqNote/2);   
    else:
        freqNote = noteFreqOct7["S"]; 
    print (note,noteLetter,noteOctave,freqNote);
    return (freqNote)

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

def freqFromNotes(vSplitNotes):
    vSplitHF=[];
    VSplitLF=[];
    print (vSplitNotes);
    for note in vSplitNotes:
        print (note);
        freqNote = octaveNotes(note);
        # Obtener high y low bytes
        high_byte = (freqNote >> 8) & 0xFF;
        low_byte = freqNote & 0xFF;
        vSplitHF.append(high_byte);
        VSplitLF.append(low_byte);
    return vSplitHF,VSplitLF

def formatAssembler(vSplitted,vSplitWave,vSplitHF,vSplitLF):
    chunk_size = 10;
    vToPrint=[];
    vWaveToPrint=[];
    vHFToPrint=[];
    vLFToPrint=[];
    print("voiceNotes:");
    for i in range(0, len(vSplitted), chunk_size):
        vToPrint.append(vSplitted[i:i + chunk_size]);
    for line in vToPrint:
        lineAssemblerAscii= "  .ascii \""
        for element in line:
            lineAssemblerAscii += element + ","
        print (lineAssemblerAscii[:-1]+"\"");   
    print("voiceWaves:");  
    for i in range(0, len(vSplitWave), chunk_size):
        vWaveToPrint.append(vSplitWave[i:i + chunk_size]);
    for line in vWaveToPrint:
        lineAssemblerByte= "  .byte "
        for element in line:
            lineAssemblerByte += str(element) + ","
        print (lineAssemblerByte[:-1]);  
    print ("voiceHighFrequencies:")
    for i in range(0, len(vSplitHF), chunk_size):
        vHFToPrint.append(vSplitHF[i:i + chunk_size]);
    for line in vHFToPrint:
        lineAssemblerByteHF= "  .byte "
        for element in line:
            lineAssemblerByteHF += f"${element:02X}" + ","
        print (lineAssemblerByteHF[:-1]);  
    print ("voiceLowFrequencies:")
    for i in range(0, len(vSplitLF), chunk_size):
        vLFToPrint.append(vSplitLF[i:i + chunk_size]);
    for line in vLFToPrint:
        lineAssemblerByteLF= "  .byte "
        for element in line:
            lineAssemblerByteLF += f"${element:02X}" + ","
        print (lineAssemblerByteLF[:-1]);  





def main():
    #print(noteDecoder());
    #voiceSplitter();
    octaveNotes("a4");
    octaveNotes("c#7");
    octaveNotes("c#9");
    octaveNotes("s0");
    v1Wave=17;
    v1Source=[594,594,594,596,596,1618,587,592,587,585,331,336,
             1097,583,585,585,585,587,587,1609,585,331,337,594,594,593,
             1618,594,596,594,592,587,1616,587,585,331,336,841,327,1607];
    v1SplitNotes,v1SplitWave=sliceNotes(v1Source,v1Wave);
    v1SplitHF,V1SplitLF=freqFromNotes(v1SplitNotes);
    formatAssembler(v1SplitNotes,v1SplitWave,v1SplitHF,V1SplitLF);
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