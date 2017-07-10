using Curses;

struct elf64_header {
    uchar       e_ident[16];
    uint16      e_type;
    uint16      e_machine;
    uint32      e_version;
    uint64      e_entry;
    uint64      e_phoff;
    uint64      e_shoff;
    uint32      e_flags;
    uint16      e_ehsize;
    uint16      e_phentsize;
    uint16      e_phnum;
    uint16      e_shentsize;
    uint16      e_shnum;
    uint16      e_shstrndx;
}

struct elf64_phdr {
   uint32   p_type;
   uint32   p_flags;
   uint64   p_offset;
   uint64   p_vaddr;
   uint64   p_paddr;
   uint64   p_filesz;
   uint64   p_memsz;
   uint64   p_align;
}

struct elf32_header {
    uchar       e_ident[16];
    uint16      e_type;
    uint16      e_machine;
    uint32      e_version;
    uint32      e_entry;
    uint32      e_phoff;
    uint32      e_shoff;
    uint32      e_flags;
    uint16      e_ehsize;
    uint16      e_phentsize;
    uint16      e_phnum;
    uint16      e_shentsize;
    uint16      e_shnum;
    uint16      e_shstrndx;
}

void readelf(string filename)
{
	var file = File.new_for_path(filename);
	if (!file.query_exists())
	{
		stderr.printf("File does not exist!\n");
		return;
	}
	var file_stream = file.read();
	var data_stream = new DataInputStream(file_stream);
	//data_stream.set_byte_order(DataStreamByteOrder.LITTLE_ENDIAN);
	var header_bytes = data_stream.read_bytes(16);
	elf64_header h = { };
	h.e_ident = header_bytes.get_data();
	
	uchar[] ref_magic = { 0x7f, 'E', 'L', 'F' };
	
	for (var i = 0; i < 4; i++)
	{
		if (ref_magic[i] != h.e_ident[i])
		{
			stderr.printf("%s is not ELF file\n", filename);
			return;
		}
	}
	
	int arch;
	switch (h.e_ident[0x04])
	{
		case 1:
			arch = 32;
			break;
		case 2:
			arch = 64;
			break;
		default:
			stderr.printf("Unknown ELF class %hhu\n", h.e_ident[0x04]);
			return;
	}
	
	switch (h.e_ident[0x05])
	{
		case 1:
			data_stream.set_byte_order(DataStreamByteOrder.LITTLE_ENDIAN);
			break;
		case 2:
			data_stream.set_byte_order(DataStreamByteOrder.BIG_ENDIAN);
			break;
		default:
			stderr.printf("Unknown ELF machine endianess %hhu\n", h.e_ident[0x05]);
			return;
	}
	
	if (h.e_ident[0x06] != 1)
	{
		stderr.printf("Unknown ELF version %hhu\n", h.e_ident[0x06]);
		return;
	}
	
	switch (h.e_ident[0x07])
	{
		case 0x00:
			stdout.printf("System-V ELF\n");
			break;
		case 0x01:
			break;
		case 0x02:
			break;
		case 0x03:
			stdout.printf("Linux ELF\n");
			break;
		case 0x06:
			break;
		case 0x07:
			break;
		case 0x08:
			break;
		case 0x09:
			break;
		case 0x0C:
			break;
		case 0x0D:
			break;
		default:
			stderr.printf("WARNING: Unknown target operating system ABI\n");
			break;
	}
	
	/* skipping the rest of e_ident */
	
	h.e_type = data_stream.read_uint16();
	h.e_machine = data_stream.read_uint16();
	h.e_version = data_stream.read_uint32();
	h.e_entry = data_stream.read_uint64();
	h.e_phoff = data_stream.read_uint64();
	h.e_shoff = data_stream.read_uint64();
	
	stdout.printf("PHoff 0x%llx\n", h.e_phoff);
	stdout.printf("Entry 0x%llx\n", h.e_entry);
	
	// goto program header offset
	data_stream.seek((int64)h.e_phoff, SeekType.SET);
	
	elf64_phdr ph = { };
	ph.p_type = data_stream.read_uint32();
	
}

int main (string[] args)
{
	if (args.length <= 1)
	{
		stderr.printf("Usage: %s filename\n", args[0]);
		return 1;
	}

	readelf(args[1]);

	return 0;

    /* Initialize Curses */
    initscr ();

    /* Initialize color mode and define a color pair */
    start_color ();
    init_pair (1, Color.GREEN, Color.RED);

    /* Create a window (height/lines, width/columns, y, x) */
    var win = new Window (LINES - 8, COLS - 8, 4, 4);
    win.bkgdset (COLOR_PAIR (1) | Attribute.BOLD);  // set background
    win.addstr ("Hello world!");   // write string
    win.clrtobot ();               // clear to bottom (does not move cursor)
    win.getch ();                  // read a character

    /* Reset the terminal mode */
    endwin ();

    return 0;
}
