#include <stdbool.h>

#include "file.h"
#include "lib.h"
#include "print.h"
#include "debug.h"

struct FileGlobals file_globals = {
	{ 0x30000000 },
	{ 0x00, 0xe5 }
};

// Get the BPB (BIOS Parameter Block) from the boot disk
static struct BPB* get_fs_bpb(struct DiskAddresses addresses) {
	uint32_t lba = *(uint32_t*)((uint64_t)addresses.fs_base_address + 0x1be + 8);
	return (struct BPB*)((uint64_t)addresses.fs_base_address + lba * 512);
}

// Get the FAT from the disk
static uint16_t *get_fat_table(struct DiskAddresses addresses) {
 	struct BPB* p = get_fs_bpb(addresses);
	uint32_t offset = (uint32_t)p->reserved_sector_count * p->bytes_per_sector;
	return (uint16_t *)((uint8_t*)p + offset);
}

// Get the next cluster value from cluster_index
static uint16_t get_cluster_value(uint32_t cluster_index, struct DiskAddresses addresses) {
	uint16_t *fat_table = get_fat_table(addresses);
	return fat_table[cluster_index];
}

// Get the cluster offset from the BPB
static uint32_t get_cluster_offset(uint32_t index, struct DiskAddresses addresses) {
	uint32_t res_size;
	uint32_t fat_size;
	uint32_t dir_size;
	assert(index >= 2);
	struct BPB* p = get_fs_bpb(addresses);
	res_size = (uint32_t)p->reserved_sector_count * p->bytes_per_sector;
	fat_size = (uint32_t)p->fat_count * p->sectors_per_fat * p->bytes_per_sector;
	dir_size = (uint32_t)p->root_entry_count * sizeof(struct DirEntry);
	return res_size + fat_size + dir_size + (index - 2) * ((uint32_t)p->sectors_per_cluster * p->bytes_per_sector);
}

// Get the cluster size in bytes from the BPB
static uint32_t get_cluster_size(struct DiskAddresses addresses) {
	struct BPB* bpb = get_fs_bpb(addresses);
	return (uint32_t)bpb->bytes_per_sector * bpb->sectors_per_cluster;
}

// Get the root directory count from the BPB
static uint32_t get_root_directory_count(struct DiskAddresses addresses) {
	struct BPB* bpb = get_fs_bpb(addresses);
	return bpb->root_entry_count;
}

// Get the root directory from the disk
static struct DirEntry *get_root_directory(struct DiskAddresses addresses) {
	struct BPB *p; 
	uint32_t offset;
	p = get_fs_bpb(addresses);
	offset = (p->reserved_sector_count + (uint32_t)p->fat_count * p->sectors_per_fat) * p->bytes_per_sector;
	return (struct DirEntry *)((uint8_t*)p + offset);
}

// Check if dir_entry has the same filename as name
static bool is_file_name_equal(struct DirEntry *dir_entry, char *name, char *ext) {
	bool status = false;
    if (memcmp(dir_entry->name, name, 8) == 0 && memcmp(dir_entry->ext, ext, 3) == 0) {
		status = true;
	}
	return status;
}

// Check if path is a split path
static bool split_path(char *path, char *name, char *ext) {
	int i;
	for (i = 0; i < 8 && path[i] != '.' && path[i] != '\0'; i++) {
		if (path[i] == '/') {
			return false;
		}
		name[i] = path[i];
	}
	if (path[i] == '.') {
		i++;
        for (int j = 0; j < 3 && path[i] != '\0'; i++, j++) {
			if (path[i] == '/') {
				return false;
			}
			ext[j] = path[i];
		}
	}
	if (path[i] != '\0') {
		return false;
	}
	return true;
}

// Search the disk for the file located in the path
static uint32_t search_file(char *path, struct FileGlobals globals) {
	char name[8] = {"        "};
	char ext[3] =  {"   "};
	uint32_t root_entry_count;
	struct DirEntry *dir_entry;
	bool status = split_path(path, name, ext);
	if (status == true) {
		root_entry_count = get_root_directory_count(globals.addresses);
		dir_entry = get_root_directory(globals.addresses);
		for (uint32_t i = 0; i < root_entry_count; i++) {
			if (dir_entry[i].name[0] == globals.attr_types.entry_empty)
				continue;
			if (dir_entry[i].name[0] == globals.attr_types.entry_deleted)
				continue;
			if (dir_entry[i].attributes == 0xf)
				continue;
			if (is_file_name_equal(&dir_entry[i], name, ext))
				return i;
		}
	}
	return 0xffffffff;
}

// Read the file from the disk given the first cluster
static uint32_t read_file(uint32_t cluster_index, void *buffer, uint32_t size, struct DiskAddresses addresses) {
	struct BPB* bpb;
	char *data;
	uint32_t read_size = 0;
	uint32_t cluster_size; 
	uint32_t index;
	bpb = get_fs_bpb(addresses);
	cluster_size = get_cluster_size(addresses);
	index = cluster_index;
	if (index < 2)
		return 0xffffffff;
	while (read_size < size) {
		data  = (char *)((uint64_t)bpb + get_cluster_offset(index, addresses));
		index = get_cluster_value(index, addresses);
		if (index >= 0xfff7) {
			memcpy(buffer, data, size - read_size);
			read_size += size - read_size;
			break;
		}
		memcpy(buffer, data, cluster_size);
		buffer += cluster_size;
		read_size += cluster_size;
	}
	return read_size;
}

// Find the file from path and load it to addr
int load_file(char *path, uint64_t addr, struct FileGlobals globals) {
	uint32_t index;
	uint32_t file_size;
	uint32_t cluster_index;
	struct DirEntry *dir_entry;
	int ret = -1;
	index = search_file(path, globals);
	if (index != 0xffffffff) {
		dir_entry = get_root_directory(globals.addresses);
		file_size = dir_entry[index].file_size;
		cluster_index = dir_entry[index].cluster_index;
		if (read_file(cluster_index, (void*)addr, file_size, globals.addresses) == file_size)
			ret = 0;
	}
	return ret;
}
