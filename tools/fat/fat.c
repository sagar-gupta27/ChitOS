#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/types.h>
#include <ctype.h>
typedef unsigned char bool;
#define true 1
#define false 0


typedef struct {
    uint8_t jmp[3];
    uint8_t oem[8];
    uint16_t bytes_per_sector;
    uint8_t  sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t fat_count;
    uint16_t max_root_dir_entries;
    uint16_t total_sectors;
    uint8_t media_descriptor;
    uint16_t sectors_per_fat;
    uint16_t sectors_per_track;
    uint16_t heads;
    uint32_t hidden_sectors;
    uint32_t total_sectors_large;

    // Extended Boot Signature
    uint8_t drive_number;
    uint8_t _reserved;
    uint8_t boot_signature;
    uint32_t volume_id;
    uint8_t volume_label[11];
    uint8_t file_system_type[8];
    
} __attribute__((packed)) fat12_boot_sector_t;


typedef struct {
    uint8_t name[11];
    uint8_t attr;
    uint8_t _reserved;
    uint8_t time_created_tenths;
    uint16_t time_created;
    uint16_t date_created;
    uint16_t date_last_accessed;
    uint16_t start_cluster_high;
    uint16_t time_modified;
    uint16_t date_modified;
    uint16_t start_cluster_low;
    uint32_t file_size;
    
} __attribute__((packed)) fat12_dir_entry_t;

fat12_boot_sector_t boot_sector;
fat12_dir_entry_t *g_root_dir = NULL;
unsigned char* g_fat12 = NULL;
uint32_t g_root_dir_end;


bool read_fat12_sector(FILE *disk, uint32_t lba, uint32_t count, void *buffer);



bool read_fat12(FILE* disk){
     g_fat12 = malloc(boot_sector.sectors_per_fat * boot_sector.bytes_per_sector);
    if (g_fat12 == NULL) {
        perror("Failed to allocate memory for FAT12");
        return false;
    }

   return read_fat12_sector(disk, boot_sector.reserved_sectors, boot_sector.sectors_per_fat, g_fat12);    
}

bool read_fat12_sector(FILE *disk, uint32_t lba, uint32_t count,void* buffer) {
    
    if (fseek(disk, lba * boot_sector.bytes_per_sector, SEEK_SET) != 0) {
        perror("Failed to seek to LBA");
        return false;
    }

    if (fread(buffer, boot_sector.bytes_per_sector, count, disk) != count) {
        perror("Failed to read from disk");
        return false;
    }
    return true;

}

bool read_fat12_root_dir(FILE* disk)
{
    uint32_t lba = boot_sector.reserved_sectors + boot_sector.sectors_per_fat * boot_sector.fat_count;
    uint32_t size = sizeof(fat12_dir_entry_t) * boot_sector.max_root_dir_entries;
    uint32_t sectors = (size / boot_sector.bytes_per_sector);
    if (size % boot_sector.bytes_per_sector > 0)
        sectors++;
   
    g_root_dir_end = lba + sectors;
    g_root_dir = (fat12_dir_entry_t*) malloc(sectors * boot_sector.bytes_per_sector);
   
    return read_fat12_sector(disk, lba, sectors, g_root_dir);
}

fat12_dir_entry_t* find_file(const char* filename){
    for (int i = 0; i < boot_sector.max_root_dir_entries; i++) {
    
        if (memcmp(g_root_dir[i].name, filename, 11) == 0) {
            return &g_root_dir[i];
        }
    }

    return NULL;
}

bool read_fat12_boot_sector(FILE *disk) {
    if (fread(&boot_sector, sizeof(fat12_boot_sector_t), 1, disk) != 1) {
        perror("Failed to read boot sector");
        return false;
    }
    return true;
}



bool read_fat12_file(FILE *disk, fat12_dir_entry_t *file, uint8_t *buffer) {
    uint16_t cluster = file->start_cluster_low;
    bool ret = true;
    do {
        uint32_t lba = g_root_dir_end + ((cluster - 2) * boot_sector.sectors_per_cluster);
        uint32_t count = boot_sector.sectors_per_cluster;
        ret = ret && read_fat12_sector(disk, lba, count, buffer);

        

        buffer += boot_sector.sectors_per_cluster * boot_sector.bytes_per_sector;   
        
        uint32_t fatIndex = cluster * 3 / 2;
        if (cluster % 2 == 0) {
            cluster = (*(uint16_t*)(g_fat12 + fatIndex)) & 0x0FFF;
        } else {
            cluster = (*(uint16_t*)(g_fat12 + fatIndex)) >> 4;
        }


    }while(ret && cluster < 0x0FF8);

    return ret;
}
int main(int argc, char **argv ){
    
    if(argc <3){
        printf("Usage: %s <disk image> <file name>\n", argv[0]);
        return -1;
    }
 
    FILE *disk = fopen(argv[1], "rb");
    if (!disk) {
        perror("Failed to open disk image");
        return -1;
    }

    if(!read_fat12_boot_sector(disk)){
        fclose(disk);
        return -1;
    }

    if(!read_fat12(disk)){
        free(g_fat12);
        return -1;
    }

    if(!read_fat12_root_dir(disk)){
        free(g_fat12);
        free(g_root_dir);
        return -1;
    }

    for (int i = 0; i < boot_sector.max_root_dir_entries; i++) {
        if (g_root_dir[i].name[0] == 0x00) break; // End of directory
        if (g_root_dir[i].name[0] == 0xE5) continue; // Deleted file
    
        printf("Entry %d: %.11s\n", i, g_root_dir[i].name);  // Print raw FAT filename
    }
    
    fat12_dir_entry_t *file = find_file(argv[2]);
    if (file) {
        fwrite(file->name, 1, 11, stdout);
        printf("File size: %u bytes\n", file->file_size);
        printf("Starting cluster: %u\n", file->start_cluster_low);
    } else {
        free(g_fat12);
        free(g_root_dir);
        printf("File not found: %s\n", argv[2]);
        return -1;
    }

    //Read data from file
    uint8_t *buffer = (uint8_t *)malloc(file->file_size + boot_sector.bytes_per_sector);
    if (!read_fat12_file(disk, file, buffer)) {
        free(buffer);
        free(g_fat12);
        free(g_root_dir);
        fclose(disk);
        return -1;
    }

    for (size_t i = 0; i < file->file_size; i++) {
        if (isprint(buffer[i])) fputc(buffer[i], stdout);
        else printf("<%02x>", buffer[i]);
    }
    printf("\n");
    free(buffer);
    free(g_root_dir);
    free(g_fat12);
    fclose(disk);
    return 0;
}