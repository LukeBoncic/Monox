#ifndef _FILE_H_
#define _FILE_H_

#include <stdint.h>

struct BPB {
	uint8_t jump[3];
	uint8_t oem[8];
	uint16_t bytes_per_sector;
	uint8_t sectors_per_cluster;
	uint16_t reserved_sector_count;
	uint8_t fat_count;
	uint16_t root_entry_count;
	uint16_t sector_count;
	uint8_t media_type;
	uint16_t sectors_per_fat;
	uint16_t sectors_per_track;
	uint16_t head_count;
	uint32_t hidden_sector_count;
	uint32_t large_sector_count;
	uint8_t drive_number;
	uint8_t flags;
	uint8_t signature;
	uint32_t volume_id;
	uint8_t volume_label[11];
	uint8_t file_system[8];
} __attribute__((packed));

struct DirEntry {
	uint8_t name[8];
	uint8_t ext[3];
	uint8_t attributes;
	uint8_t reserved;
	uint8_t create_ms;
	uint16_t create_time;
	uint16_t create_date;
	uint16_t access_date;
	uint16_t attr_index;
	uint16_t m_time;
	uint16_t m_date;
	uint16_t cluster_index;
	uint32_t file_size;
} __attribute__((packed));

struct DiskAddresses {
	uint64_t fs_base_address;
};

struct AttributeTypes {
	uint8_t entry_empty;
	uint8_t entry_deleted;
};

struct FileGlobals {
	struct DiskAddresses addresses;
	struct AttributeTypes attr_types;
};

extern struct FileGlobals file_globals;

// Find the file from path and load it to addr
int load_file(char *path, uint64_t addr, struct FileGlobals globals);

#endif
