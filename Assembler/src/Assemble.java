import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Scanner;

public class Assemble
{
    public static void main(String[] args) throws IOException {
	Scanner sc = new Scanner(System.in);
	if(args.length != 2) {
	    System.out.println("The number of arguments has to be 2: the assembly file as the first and the output file as the second.");
	    System.exit(0);
	}
	if(!(new File(args[0]).exists())) {
	    System.out.println("The assembly file does not exist.");
	    System.exit(0);
	}

	if(new File(args[1]).exists()) {
	    System.out.print("The output file already exists! Overwrite it? y/n ? ");
	    String ov = sc.nextLine();
	    if(ov.equalsIgnoreCase("y")) {
		new File(args[1]).delete();
	    } else {
		System.out.println("Exiting...");
		System.exit(0);
	    }
	}
	if(new File("hulttmp-assembly.hult").exists()) {
	    new File("hulttmp-assembly.hult").delete();
	}
	PrintWriter writer = new PrintWriter("hulttmp-assembly.hult", "UTF-8");
	ArrayList<BufferedReader> brs = new ArrayList<BufferedReader>();
	brs.add(new BufferedReader(new FileReader(args[0])));
	String line = null;
	int pmCounter = 2;
	HashMap<String, Integer> labels = new HashMap<String, Integer>();
	int fileLineNr = 0;


	//NOPS
	writer.println("0 => B\"000000_0000_00_0000\", -- NOPs");
	writer.println("1 => B\"000000_0000_00_0000\", -- NOPs");

	String[] s = null;
	while(brs.size() > 0) {
	    //System.out.println(brs.size());
	    //System.out.println(brs.get(brs.size() - 1).toString());
	    while((line = brs.get(brs.size() - 1).readLine()) != null) {
		fileLineNr++;
		try {
		    line = line.trim();
		    String ass = line.split(";")[0];
			String comment = "";
			if (line.split(";").length >= 2) 
				comment = line.split(";", 2)[1];
		    if(!ass.equalsIgnoreCase("")) {
			s = split(ass, " ");
			String cmd = s[0].trim().toUpperCase();
			String operand = "0000000000000000";
			String addmod = "00";
			String grx = "0000";
			String ind = "0000";
			boolean cont = true;

			if(!cmd.equalsIgnoreCase("INCLUDE")) {
			    String opCode = "000000";
			    if(cmd.equalsIgnoreCase("NOP"))
				    opCode = "000000";
			    else if(cmd.equalsIgnoreCase("ADD"))
				    opCode = "000001";
			    else if(cmd.equalsIgnoreCase("SUB"))
				    opCode = "000010";
			    else if(cmd.equalsIgnoreCase("BTST"))
				    opCode = "000011";
			    else if(cmd.equalsIgnoreCase("CMP"))
				    opCode = "000100";
			    else if(cmd.equalsIgnoreCase("AND"))
				    opCode = "000101";
			    else if(cmd.equalsIgnoreCase("OR"))
				    opCode = "000110";
			    else if(cmd.equalsIgnoreCase("XOR"))
				    opCode = "000111";
			    else if(cmd.equalsIgnoreCase("NOT"))
				    opCode = "001000";
			    else if(cmd.equalsIgnoreCase("BRA"))
				    opCode = "001001";
			    else if(cmd.equalsIgnoreCase("BNE"))
				    opCode = "001010";
			    else if(cmd.equalsIgnoreCase("BEQ"))
				    opCode = "001011";
			    else if(cmd.equalsIgnoreCase("BGE"))
				    opCode = "001100";
			    else if(cmd.equalsIgnoreCase("BLT"))
				    opCode = "001101";
			    else if(cmd.equalsIgnoreCase("BPL"))
				    opCode = "001110";
			    else if(cmd.equalsIgnoreCase("BMI"))
				    opCode = "001111";
			    else if(cmd.equalsIgnoreCase("BOU"))
				    opCode = "010000";
			    else if(cmd.equalsIgnoreCase("BOS"))
				    opCode = "010001";
			    else if(cmd.equalsIgnoreCase("LSR"))
				    opCode = "010010";
			    else if(cmd.equalsIgnoreCase("LSL"))
				    opCode = "010011";
			    else if(cmd.equalsIgnoreCase("RSR"))
				    opCode = "010100";
			    else if(cmd.equalsIgnoreCase("RSL"))
				    opCode = "010101";
			    else if(cmd.equalsIgnoreCase("STORE"))
				    opCode = "010110";
			    else if(cmd.equalsIgnoreCase("LOAD"))
				    opCode = "010111";
			    else if(cmd.equalsIgnoreCase("GSTORE"))
				    opCode = "011000";
			    else if(cmd.equalsIgnoreCase("SPI"))
					opCode = "011001";
			    else if(cmd.equalsIgnoreCase("UART"))
					opCode = "011010";
				else if(cmd.equalsIgnoreCase("RAND"))
					opCode = "011011";
				else if(cmd.equalsIgnoreCase("BREAK"))
					opCode = "011100";
				else {
			    		labels.put(cmd, pmCounter);
					cont = false;
				writer.println("-- " + cmd);
			    }
				if(cont) {
				    if(s.length > 1) {
					String arg2 = s[1].trim().toUpperCase().split(",")[0].trim();
					if(arg2.substring(0,2).equalsIgnoreCase("GR")) {
					    arg2 = arg2.substring(2).trim();
					    //System.out.println(arg2);
					    grx = Integer.toBinaryString(Integer.parseInt(arg2));
					    grx = pad(grx, 4, '0');
					} else {
					    String arg1 = s[1].trim().toUpperCase().split(",")[0].trim();
						if(arg1.charAt(0) == '#')
						    addmod = "00";
						else if(arg1.charAt(0) == '(')
						    addmod = "10";
						else if(s.length == 4)
						    addmod = "11";
						else
						    addmod = "01";
					    arg1 = arg1.replace("#", "").replace("(", "").replace(")", "");
					    if(arg1.charAt(0) == '$') {
						operand = Integer.toBinaryString(Integer.parseInt(arg1.substring(1), 16));
						operand = pad(operand, 16, '0');
					    } else if(isInteger(arg1)) {
						operand = Integer.toBinaryString(Integer.parseInt(arg1, 10));
						operand = pad(operand, 16, '0');
					    } else {
						//operand = Integer.toBinaryString(labels.get(arg1.substring(1).toUpperCase()));
						//operand = pad(operand, 16, '0');
						operand = arg1;
					    }
					}
				    }
				    if(s.length > 2) {
					String arg2 = s[2].trim().toUpperCase().split(",")[0].trim();
					if(arg2.length() > 2) {
					    //System.out.println(arg2.substring(0, 2));
					    if(arg2.substring(0,2).equalsIgnoreCase("GR")) {
						arg2 = arg2.substring(2).trim();
						//System.out.println(arg2);
						grx = Integer.toBinaryString(Integer.parseInt(arg2));
						grx = pad(grx, 4, '0');
					    }
					}
				    }
				    if(s.length > 3) {
					String arg3 = s[3].trim().toUpperCase().split(",")[0].trim();
					if(arg3.substring(0,2).equalsIgnoreCase("GR")) {
					    arg3 = arg3.substring(2).trim();
					    ind = Integer.toBinaryString(Integer.parseInt(arg3));
					    ind = pad(ind, 4, '0');
					}
				    }
				    //System.out.println("wrote shit");
				    writer.println(pmCounter + " => B\"" + opCode + "_" + grx + "_" + addmod + "_" + ind + "\"," + " -- \"" + ass + "\"" + " ; " + comment);
				    if (isInteger(operand))
				    	writer.println((pmCounter + 1)+ " => \"" + operand + "\", -- " + Integer.parseInt(operand, 2));
				    else
					writer.println((pmCounter + 1)+ " => \"" + operand + "\",");
				    pmCounter += 2;
				} else {

				}
			    //System.out.println("\"" + cmd + "\"");
			} else {
			    String file = s[1].trim().replace("\"", "");
			    if(!(new File(file).exists())) {
				    System.out.println("The import-file \"" + file + "\" could not be found!");
				    System.exit(0);
				}
				fileLineNr++;
			    brs.add(new BufferedReader(new FileReader(file)));
			}
		    }
		} catch (Exception e) {
		    e.printStackTrace();
		    System.out.println();
		    System.out.println(line);
		    System.out.println();

		    System.out.println(Arrays.toString(s));
			System.out.println();
			System.out.println("LineNr: " + fileLineNr);
		    System.exit(0);
		}
	    }
	    brs.get(brs.size() - 1).close();
	    brs.remove(brs.size() - 1);
	}
	writer.println("others => B\"000000_0000_00_0000\"");
	writer.close();
	BufferedReader br = new BufferedReader(new FileReader("hulttmp-assembly.hult"));
	PrintWriter out = new PrintWriter(args[1], "UTF-8");
	String inp = null;
	for (String lbl : labels.keySet()) { System.out.println(lbl + ": " + labels.get(lbl)); }
	while((inp = br.readLine()) != null) {
	    String replace = null;
	    for(String lbl : labels.keySet()) {
		if (inp.toUpperCase().contains(lbl)) {
		    inp = inp.replaceAll(lbl + "\",", pad(Integer.toBinaryString(labels.get(lbl)), 16, '0') + "\",");
			replace = labels.get(lbl).toString();
		}
	    }
	    if(replace != null)
	    	out.println(inp + " -- " + replace);
	    else
		out.println(inp);
	}
	out.close();
	br.close();
	new File("hulttmp-assembly.hult").delete();
    }

    public static String pad(String str, int size, char padChar)
    {
      String padded = str;
	  if(padded.length() < size) {
		  while (padded.length() < size)
		  {
			padded = padChar + padded;
		  }
	  } else if(padded.length() > size) {
		padded = padded.substring(padded.length()-size);
	  }
      return padded;
    }

    public static boolean isInteger(String s) {
        try {
            Integer.parseInt(s);
        } catch(NumberFormatException e) {
            return false;
        }
        // only got here if we didn't return false
        return true;
    }

    public static String[] split(String str, String delim) {
	String[] res2 = str.split(delim);
	ArrayList<String> list = new ArrayList<String>();
	for(String s : res2) {
	    if(!s.trim().equalsIgnoreCase("")) {
		list.add(s);
	    }
	}
	String[] res = new String[list.size()];
	for(int i = 0; i < list.size(); i++)
	    res[i] = list.get(i);
	return res;
    }
}
