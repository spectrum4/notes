

# 1 "drivers/pci/controller/pcie-brcmstb.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 400 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "drivers/pci/controller/pcie-brcmstb.c" 2
# 35 "drivers/pci/controller/pcie-brcmstb.c"
# 1 "drivers/pci/controller/../pci.h" 1
# 14 "drivers/pci/controller/../pci.h"
extern const unsigned char pcie_link_speed[];
extern bool pci_early_dump;

bool pcie_cap_has_lnkctl(const struct pci_dev *dev);
bool pcie_cap_has_lnkctl2(const struct pci_dev *dev);
bool pcie_cap_has_rtctl(const struct pci_dev *dev);



int pci_create_sysfs_dev_files(struct pci_dev *pdev);
void pci_remove_sysfs_dev_files(struct pci_dev *pdev);
void pci_cleanup_rom(struct pci_dev *dev);




enum pci_mmap_api {
 PCI_MMAP_SYSFS,
 PCI_MMAP_PROCFS
};
int pci_mmap_fits(struct pci_dev *pdev, int resno, struct vm_area_struct *vmai,
    enum pci_mmap_api mmap_api);

bool pci_reset_supported(struct pci_dev *dev);
void pci_init_reset_methods(struct pci_dev *dev);
int pci_bridge_secondary_bus_reset(struct pci_dev *dev);
int pci_bus_error_reset(struct pci_dev *dev);

struct pci_cap_saved_data {
 u16 cap_nr;
 bool cap_extended;
 unsigned int size;
 u32 data[];
};

struct pci_cap_saved_state {
 struct hlist_node next;
 struct pci_cap_saved_data cap;
};

void pci_allocate_cap_save_buffers(struct pci_dev *dev);
void pci_free_cap_save_buffers(struct pci_dev *dev);
int pci_add_cap_save_buffer(struct pci_dev *dev, char cap, unsigned int size);
int pci_add_ext_cap_save_buffer(struct pci_dev *dev,
    u16 cap, unsigned int size);
struct pci_cap_saved_state *pci_find_saved_cap(struct pci_dev *dev, char cap);
struct pci_cap_saved_state *pci_find_saved_ext_cap(struct pci_dev *dev,
         u16 cap);





void pci_update_current_state(struct pci_dev *dev, pci_power_t state);
void pci_refresh_power_state(struct pci_dev *dev);
int pci_power_up(struct pci_dev *dev);
void pci_disable_enabled_device(struct pci_dev *dev);
int pci_finish_runtime_suspend(struct pci_dev *dev);
void pcie_clear_device_status(struct pci_dev *dev);
void pcie_clear_root_pme_status(struct pci_dev *dev);
bool pci_check_pme_status(struct pci_dev *dev);
void pci_pme_wakeup_bus(struct pci_bus *bus);
int __pci_pme_wakeup(struct pci_dev *dev, void *ign);
void pci_pme_restore(struct pci_dev *dev);
bool pci_dev_need_resume(struct pci_dev *dev);
void pci_dev_adjust_pme(struct pci_dev *dev);
void pci_dev_complete_resume(struct pci_dev *pci_dev);
void pci_config_pm_runtime_get(struct pci_dev *dev);
void pci_config_pm_runtime_put(struct pci_dev *dev);
void pci_pm_init(struct pci_dev *dev);
void pci_ea_init(struct pci_dev *dev);
void pci_msi_init(struct pci_dev *dev);
void pci_msix_init(struct pci_dev *dev);
bool pci_bridge_d3_possible(struct pci_dev *dev);
void pci_bridge_d3_update(struct pci_dev *dev);
void pci_bridge_wait_for_secondary_bus(struct pci_dev *dev);
void pci_bridge_reconfigure_ltr(struct pci_dev *dev);

static inline void pci_wakeup_event(struct pci_dev *dev)
{

 pm_wakeup_event(&dev->dev, 100);
}

static inline bool pci_has_subordinate(struct pci_dev *pci_dev)
{
 return !!(pci_dev->subordinate);
}

static inline bool pci_power_manageable(struct pci_dev *pci_dev)
{




 return !pci_has_subordinate(pci_dev) || pci_dev->bridge_d3;
}

static inline bool pcie_downstream_port(const struct pci_dev *dev)
{
 int type = pci_pcie_type(dev);

 return type == PCI_EXP_TYPE_ROOT_PORT ||
        type == PCI_EXP_TYPE_DOWNSTREAM ||
        type == PCI_EXP_TYPE_PCIE_BRIDGE;
}

void pci_vpd_init(struct pci_dev *dev);
void pci_vpd_release(struct pci_dev *dev);
extern const struct attribute_group pci_dev_vpd_attr_group;


int pci_save_vc_state(struct pci_dev *dev);
void pci_restore_vc_state(struct pci_dev *dev);
void pci_allocate_vc_save_buffers(struct pci_dev *dev);







static inline int pci_proc_attach_device(struct pci_dev *dev) { return 0; }
static inline int pci_proc_detach_device(struct pci_dev *dev) { return 0; }
static inline int pci_proc_detach_bus(struct pci_bus *bus) { return 0; }



int pci_hp_add_bridge(struct pci_dev *dev);





static inline void pci_create_legacy_files(struct pci_bus *bus) { return; }
static inline void pci_remove_legacy_files(struct pci_bus *bus) { return; }



extern struct rw_semaphore pci_bus_sem;
extern struct mutex pci_slot_mutex;

extern raw_spinlock_t pci_lock;

extern unsigned int pci_pm_d3hot_delay;




static inline void pci_no_msi(void) { }


void pci_realloc_get_opt(char *);

static inline int pci_no_d1d2(struct pci_dev *dev)
{
 unsigned int parent_dstates = 0;

 if (dev->bus->self)
  parent_dstates = dev->bus->self->no_d1d2;
 return (dev->no_d1d2 || parent_dstates);

}
extern const struct attribute_group *pci_dev_groups[];
extern const struct attribute_group *pcibus_groups[];
extern const struct device_type pci_dev_type;
extern const struct attribute_group *pci_bus_groups[];

extern unsigned long pci_hotplug_io_size;
extern unsigned long pci_hotplug_mmio_size;
extern unsigned long pci_hotplug_mmio_pref_size;
extern unsigned long pci_hotplug_bus_size;
# 195 "drivers/pci/controller/../pci.h"
static inline const struct pci_device_id *
pci_match_one_device(const struct pci_device_id *id, const struct pci_dev *dev)
{
 if ((id->vendor == PCI_ANY_ID || id->vendor == dev->vendor) &&
     (id->device == PCI_ANY_ID || id->device == dev->device) &&
     (id->subvendor == PCI_ANY_ID || id->subvendor == dev->subsystem_vendor) &&
     (id->subdevice == PCI_ANY_ID || id->subdevice == dev->subsystem_device) &&
     !((id->class ^ dev->class) & id->class_mask))
  return id;
 return NULL;
}




extern struct kset *pci_slots_kset;

struct pci_slot_attribute {
 struct attribute attr;
 ssize_t (*show)(struct pci_slot *, char *);
 ssize_t (*store)(struct pci_slot *, const char *, size_t);
};


enum pci_bar_type {
 pci_bar_unknown,
 pci_bar_io,
 pci_bar_mem32,
 pci_bar_mem64,
};

struct device *pci_get_host_bridge_device(struct pci_dev *dev);
void pci_put_host_bridge_device(struct device *dev);

int pci_configure_extended_tags(struct pci_dev *dev, void *ign);
bool pci_bus_read_dev_vendor_id(struct pci_bus *bus, int devfn, u32 *pl,
    int crs_timeout);
bool pci_bus_generic_read_dev_vendor_id(struct pci_bus *bus, int devfn, u32 *pl,
     int crs_timeout);
int pci_idt_bus_quirk(struct pci_bus *bus, int devfn, u32 *pl, int crs_timeout);

int pci_setup_device(struct pci_dev *dev);
int __pci_read_base(struct pci_dev *dev, enum pci_bar_type type,
      struct resource *res, unsigned int reg);
void pci_configure_ari(struct pci_dev *dev);
void __pci_bus_size_bridges(struct pci_bus *bus,
   struct list_head *realloc_head);
void __pci_bus_assign_resources(const struct pci_bus *bus,
    struct list_head *realloc_head,
    struct list_head *fail_head);
bool pci_bus_clip_resource(struct pci_dev *dev, int idx);

void pci_reassigndev_resource_alignment(struct pci_dev *dev);
void pci_disable_bridge_window(struct pci_dev *dev);
struct pci_bus *pci_bus_get(struct pci_bus *bus);
void pci_bus_put(struct pci_bus *bus);
# 272 "drivers/pci/controller/../pci.h"
const char *pci_speed_string(enum pci_bus_speed speed);
enum pci_bus_speed pcie_get_speed_cap(struct pci_dev *dev);
enum pcie_link_width pcie_get_width_cap(struct pci_dev *dev);
u32 pcie_bandwidth_capable(struct pci_dev *dev, enum pci_bus_speed *speed,
      enum pcie_link_width *width);
void __pcie_print_link_status(struct pci_dev *dev, bool verbose);
void pcie_report_downtraining(struct pci_dev *dev);
void pcie_update_link_speed(struct pci_bus *bus, u16 link_status);


struct pci_sriov {
 int pos;
 int nres;
 u32 cap;
 u16 ctrl;
 u16 total_VFs;
 u16 initial_VFs;
 u16 num_VFs;
 u16 offset;
 u16 stride;
 u16 vf_device;
 u32 pgsz;
 u8 link;
 u8 max_VF_buses;
 u16 driver_max_VFs;
 struct pci_dev *dev;
 struct pci_dev *self;
 u32 class;
 u8 hdr_type;
 u16 subsystem_vendor;
 u16 subsystem_device;
 resource_size_t barsz[PCI_SRIOV_NUM_BARS];
 bool drivers_autoprobe;
};
# 317 "drivers/pci/controller/../pci.h"
static inline bool pci_dev_set_io_state(struct pci_dev *dev,
     pci_channel_state_t new)
{
 bool changed = false;

 device_lock_assert(&dev->dev);
 switch (new) {
 case pci_channel_io_perm_failure:
  switch (dev->error_state) {
  case pci_channel_io_frozen:
  case pci_channel_io_normal:
  case pci_channel_io_perm_failure:
   changed = true;
   break;
  }
  break;
 case pci_channel_io_frozen:
  switch (dev->error_state) {
  case pci_channel_io_frozen:
  case pci_channel_io_normal:
   changed = true;
   break;
  }
  break;
 case pci_channel_io_normal:
  switch (dev->error_state) {
  case pci_channel_io_frozen:
  case pci_channel_io_normal:
   changed = true;
   break;
  }
  break;
 }
 if (changed)
  dev->error_state = new;
 return changed;
}

static inline int pci_dev_set_disconnected(struct pci_dev *dev, void *unused)
{
 device_lock(&dev->dev);
 pci_dev_set_io_state(dev, pci_channel_io_perm_failure);
 device_unlock(&dev->dev);

 return 0;
}

static inline bool pci_dev_is_disconnected(const struct pci_dev *dev)
{
 return dev->error_state == pci_channel_io_perm_failure;
}






static inline void pci_dev_assign_added(struct pci_dev *dev, bool added)
{
 assign_bit(0, &dev->priv_flags, added);
}

static inline bool pci_dev_is_added(const struct pci_dev *dev)
{
 return test_bit(0, &dev->priv_flags);
}
# 429 "drivers/pci/controller/../pci.h"
static inline void pci_save_dpc_state(struct pci_dev *dev) {}
static inline void pci_restore_dpc_state(struct pci_dev *dev) {}
static inline void pci_dpc_init(struct pci_dev *pdev) {}
static inline bool pci_dpc_recovered(struct pci_dev *pdev) { return false; }
# 443 "drivers/pci/controller/../pci.h"
static inline void pci_rcec_init(struct pci_dev *dev) {}
static inline void pci_rcec_exit(struct pci_dev *dev) {}
static inline void pcie_link_rcec(struct pci_dev *rcec) {}
static inline void pcie_walk_rcec(struct pci_dev *rcec,
      int (*cb)(struct pci_dev *, void *),
      void *userdata) {}







static inline void pci_ats_init(struct pci_dev *d) { }
static inline void pci_restore_ats_state(struct pci_dev *dev) { }






static inline void pci_pri_init(struct pci_dev *dev) { }
static inline void pci_restore_pri_state(struct pci_dev *pdev) { }






static inline void pci_pasid_init(struct pci_dev *dev) { }
static inline void pci_restore_pasid_state(struct pci_dev *pdev) { }
# 487 "drivers/pci/controller/../pci.h"
static inline int pci_iov_init(struct pci_dev *dev)
{
 return -ENODEV;
}
static inline void pci_iov_release(struct pci_dev *dev)

{
}
static inline void pci_iov_remove(struct pci_dev *dev)
{
}
static inline void pci_restore_iov_state(struct pci_dev *dev)
{
}
static inline int pci_iov_bus_range(struct pci_bus *bus)
{
 return 0;
}
# 515 "drivers/pci/controller/../pci.h"
static inline void pci_ptm_init(struct pci_dev *dev) { }
static inline void pci_save_ptm_state(struct pci_dev *dev) { }
static inline void pci_restore_ptm_state(struct pci_dev *dev) { }
static inline void pci_suspend_ptm(struct pci_dev *dev) { }
static inline void pci_resume_ptm(struct pci_dev *dev) { }


unsigned long pci_cardbus_resource_alignment(struct resource *);

static inline resource_size_t pci_resource_alignment(struct pci_dev *dev,
           struct resource *res)
{






 if (dev->class >> 8 == PCI_CLASS_BRIDGE_CARDBUS)
  return pci_cardbus_resource_alignment(res);
 return resource_alignment(res);
}

void pci_acs_init(struct pci_dev *dev);





static inline int pci_dev_specific_acs_enabled(struct pci_dev *dev,
            u16 acs_flags)
{
 return -ENOTTY;
}
static inline int pci_dev_specific_enable_acs(struct pci_dev *dev)
{
 return -ENOTTY;
}
static inline int pci_dev_specific_disable_acs_redir(struct pci_dev *dev)
{
 return -ENOTTY;
}



pci_ers_result_t pcie_do_recovery(struct pci_dev *dev,
  pci_channel_state_t state,
  pci_ers_result_t (*reset_subordinates)(struct pci_dev *pdev));

bool pcie_wait_for_link(struct pci_dev *pdev, bool active);







static inline void pcie_aspm_init_link_state(struct pci_dev *pdev) { }
static inline void pcie_aspm_exit_link_state(struct pci_dev *pdev) { }
static inline void pcie_aspm_powersave_config_link(struct pci_dev *pdev) { }
static inline void pci_save_aspm_l1ss_state(struct pci_dev *dev) { }
static inline void pci_restore_aspm_l1ss_state(struct pci_dev *dev) { }






static inline void pcie_set_ecrc_checking(struct pci_dev *dev) { }
static inline void pcie_ecrc_get_policy(char *str) { }


struct pci_dev_reset_methods {
 u16 vendor;
 u16 device;
 int (*reset)(struct pci_dev *dev, bool probe);
};

struct pci_reset_fn_method {
 int (*reset_fn)(struct pci_dev *pdev, bool probe);
 char *name;
};




static inline int pci_dev_specific_reset(struct pci_dev *dev, bool probe)
{
 return -ENOTTY;
}






static inline int acpi_get_rc_resources(struct device *dev, const char *hid,
     u16 segment, struct resource *res)
{
 return -ENODEV;
}


int pci_rebar_get_current_size(struct pci_dev *pdev, int bar);
int pci_rebar_set_size(struct pci_dev *pdev, int bar, int size);
static inline u64 pci_rebar_size_to_bytes(int size)
{
 return 1ULL << (size + 20);
}

struct device_node;
# 642 "drivers/pci/controller/../pci.h"
static inline int
of_pci_parse_bus_range(struct device_node *node, struct resource *res)
{
 return -EINVAL;
}

static inline int
of_get_pci_domain_nr(struct device_node *node)
{
 return -1;
}

static inline int
of_pci_get_max_link_speed(struct device_node *node)
{
 return -EINVAL;
}

static inline u32
of_pci_get_slot_power_limit(struct device_node *node,
       u8 *slot_power_limit_value,
       u8 *slot_power_limit_scale)
{
 if (slot_power_limit_value)
  *slot_power_limit_value = 0;
 if (slot_power_limit_scale)
  *slot_power_limit_scale = 0;
 return 0;
}

static inline void pci_set_of_node(struct pci_dev *dev) { }
static inline void pci_release_of_node(struct pci_dev *dev) { }
static inline void pci_set_bus_of_node(struct pci_bus *bus) { }
static inline void pci_release_bus_of_node(struct pci_bus *bus) { }

static inline int devm_of_pci_bridge_init(struct device *dev, struct pci_host_bridge *bridge)
{
 return 0;
}
# 693 "drivers/pci/controller/../pci.h"
static inline void pci_no_aer(void) { }
static inline void pci_aer_init(struct pci_dev *d) { }
static inline void pci_aer_exit(struct pci_dev *d) { }
static inline void pci_aer_clear_fatal_status(struct pci_dev *dev) { }
static inline int pci_aer_clear_status(struct pci_dev *dev) { return -EINVAL; }
static inline int pci_aer_raw_clear_status(struct pci_dev *dev) { return -EINVAL; }
# 715 "drivers/pci/controller/../pci.h"
static inline int pci_dev_acpi_reset(struct pci_dev *dev, bool probe)
{
 return -ENOTTY;
}
static inline void pci_set_acpi_fwnode(struct pci_dev *dev) {}
static inline int pci_acpi_program_hp_params(struct pci_dev *dev)
{
 return -ENODEV;
}
static inline bool acpi_pci_power_manageable(struct pci_dev *dev)
{
 return false;
}
static inline bool acpi_pci_bridge_d3(struct pci_dev *dev)
{
 return false;
}
static inline int acpi_pci_set_power_state(struct pci_dev *dev, pci_power_t state)
{
 return -ENODEV;
}
static inline pci_power_t acpi_pci_get_power_state(struct pci_dev *dev)
{
 return PCI_UNKNOWN;
}
static inline void acpi_pci_refresh_power_state(struct pci_dev *dev) {}
static inline int acpi_pci_wakeup(struct pci_dev *dev, bool enable)
{
 return -ENODEV;
}
static inline bool acpi_pci_need_resume(struct pci_dev *dev)
{
 return false;
}
static inline pci_power_t acpi_pci_choose_state(struct pci_dev *pdev)
{
 return PCI_POWER_ERROR;
}






extern const struct attribute_group pci_dev_reset_method_attr_group;






static inline bool pci_use_mid_pm(void)
{
 return false;
}
static inline int mid_pci_set_power_state(struct pci_dev *pdev, pci_power_t state)
{
 return -ENODEV;
}
static inline pci_power_t mid_pci_get_power_state(struct pci_dev *pdev)
{
 return PCI_UNKNOWN;
}
# 36 "drivers/pci/controller/pcie-brcmstb.c" 2
# 196 "drivers/pci/controller/pcie-brcmstb.c"
struct brcm_pcie;

enum {
 RGR1_SW_INIT_1,
 EXT_CFG_INDEX,
 EXT_CFG_DATA,
};

enum {
 RGR1_SW_INIT_1_INIT_MASK,
 RGR1_SW_INIT_1_INIT_SHIFT,
};

enum pcie_type {
 GENERIC,
 BCM7425,
 BCM7435,
 BCM4908,
 BCM7278,
 BCM2711,
};

struct pcie_cfg_data {
 const int *offsets;
 const enum pcie_type type;
 void (*perst_set)(struct brcm_pcie *pcie, u32 val);
 void (*bridge_sw_init_set)(struct brcm_pcie *pcie, u32 val);
};

struct subdev_regulators {
 unsigned int num_supplies;
 struct regulator_bulk_data supplies[];
};

struct brcm_msi {
 struct device *dev;
 void __iomem *base;
 struct device_node *np;
 struct irq_domain *msi_domain;
 struct irq_domain *inner_domain;
 struct mutex lock;
 u64 target_addr;
 int irq;
 DECLARE_BITMAP(used, 32);
 bool legacy;

 int legacy_shift;
 int nr;

 void __iomem *intr_base;
};


struct brcm_pcie {
 struct device *dev;
 void __iomem *base;
 struct clk *clk;
 struct device_node *np;
 bool ssc;
 int gen;
 u64 msi_target_addr;
 struct brcm_msi *msi;
 const int *reg_offsets;
 enum pcie_type type;
 struct reset_control *rescal;
 struct reset_control *perst_reset;
 int num_memc;
 u64 memc_size[3];
 u32 hw_rev;
 void (*perst_set)(struct brcm_pcie *pcie, u32 val);
 void (*bridge_sw_init_set)(struct brcm_pcie *pcie, u32 val);
 struct subdev_regulators *sr;
 bool ep_wakeup_capable;
};

static inline bool is_bmips(const struct brcm_pcie *pcie)
{
 return pcie->type == BCM7435 || pcie->type == BCM7425;
}





static int brcm_pcie_encode_ibar_size(u64 size)
{
 int log2_in = ilog2(size);

 if (log2_in >= 12 && log2_in <= 15)

  return (log2_in - 12) + 0x1c;
 else if (log2_in >= 16 && log2_in <= 35)

  return log2_in - 15;

 return 0;
}

static u32 brcm_pcie_mdio_form_pkt(int port, int regad, int cmd)
{
 u32 pkt = 0;

 pkt |= FIELD_PREP(0xf0000, port);
 pkt |= FIELD_PREP(0xffff, regad);
 pkt |= FIELD_PREP(0xfff00000, cmd);

 return pkt;
}


static int brcm_pcie_mdio_read(void __iomem *base, u8 port, u8 regad, u32 *val)
{
 u32 data;
 int err;

 writel(brcm_pcie_mdio_form_pkt(port, regad, 0x1),
     base + 0x1100);
 readl(base + 0x1100);
 err = readl_poll_timeout_atomic(base + 0x1108, data,
     (((data) & 0x80000000) ? 1 : 0), 10, 100);
 *val = FIELD_GET(0x7fffffff, data);

 return err;
}


static int brcm_pcie_mdio_write(void __iomem *base, u8 port,
    u8 regad, u16 wrdata)
{
 u32 data;
 int err;

 writel(brcm_pcie_mdio_form_pkt(port, regad, 0x0),
     base + 0x1100);
 readl(base + 0x1100);
 writel(0x80000000 | wrdata, base + 0x1104);

 err = readw_poll_timeout_atomic(base + 0x1104, data,
     (((data) & 0x80000000) ? 0 : 1), 10, 100);
 return err;
}





static int brcm_pcie_set_ssc(struct brcm_pcie *pcie)
{
 int pll, ssc;
 int ret;
 u32 tmp;

 ret = brcm_pcie_mdio_write(0xfd500000, 0x0, 0x1f,
       0x1100);
 if (ret < 0)
  return ret;

 ret = brcm_pcie_mdio_read(0xfd500000, 0x0,
      0x2, &tmp);
 if (ret < 0)
  return ret;

 u32p_replace_bits(&tmp, 1, 0x8000);
 u32p_replace_bits(&tmp, 1, 0x4000);
 ret = brcm_pcie_mdio_write(0xfd500000, 0x0,
       0x2, tmp);
 if (ret < 0)
  return ret;

 usleep_range(1000, 2000);
 ret = brcm_pcie_mdio_read(0xfd500000, 0x0,
      0x1, &tmp);
 if (ret < 0)
  return ret;

 ssc = FIELD_GET(0x400, tmp);
 pll = FIELD_GET(0x800, tmp);

 return ssc && pll ? 0 : -EIO;
}


static void brcm_pcie_set_gen(struct brcm_pcie *pcie, int gen)
{
 u16 lnkctl2 = readw(0xfd500000 + 0x00ac + PCI_EXP_LNKCTL2);
 u32 lnkcap = readl(0xfd500000 + 0x00ac + PCI_EXP_LNKCAP);

 lnkcap = (lnkcap & ~PCI_EXP_LNKCAP_SLS) | gen;
 writel(lnkcap, 0xfd500000 + 0x00ac + PCI_EXP_LNKCAP);

 lnkctl2 = (lnkctl2 & ~0xf) | gen;
 writew(lnkctl2, 0xfd500000 + 0x00ac + PCI_EXP_LNKCTL2);
}

static void brcm_pcie_set_outbound_win(struct brcm_pcie *pcie,
           unsigned int win, u64 cpu_addr,
           u64 pcie_addr, u64 size)
{
 u32 cpu_addr_mb_high, limit_addr_mb_high;
 phys_addr_t cpu_addr_mb, limit_addr_mb;
 int high_addr_shift;
 u32 tmp;


 writel(lower_32_bits(pcie_addr), 0xfd500000 + 0x400c + ((win) * 8));
 writel(upper_32_bits(pcie_addr), 0xfd500000 + 0x4010 + ((win) * 8));


 cpu_addr_mb = cpu_addr / SZ_1M;
 limit_addr_mb = (cpu_addr + size - 1) / SZ_1M;

 tmp = readl(0xfd500000 + 0x4070 + ((win) * 4));
 u32p_replace_bits(&tmp, cpu_addr_mb,
     0xfff0);
 u32p_replace_bits(&tmp, limit_addr_mb,
     0xfff00000);
 writel(tmp, 0xfd500000 + 0x4070 + ((win) * 4));

 if (is_bmips(pcie))
  return;


 high_addr_shift =
  HWEIGHT32(0xfff0);

 cpu_addr_mb_high = cpu_addr_mb >> high_addr_shift;
 tmp = readl(0xfd500000 + 0x4080 + ((win) * 8));
 u32p_replace_bits(&tmp, cpu_addr_mb_high,
     0xff);
 writel(tmp, 0xfd500000 + 0x4080 + ((win) * 8));

 limit_addr_mb_high = limit_addr_mb >> high_addr_shift;
 tmp = readl(0xfd500000 + 0x4084 + ((win) * 8));
 u32p_replace_bits(&tmp, limit_addr_mb_high,
     0xff);
 writel(tmp, 0xfd500000 + 0x4084 + ((win) * 8));
}

static struct irq_chip brcm_msi_irq_chip = {
 .name = "BRCM STB PCIe MSI",
 .irq_ack = irq_chip_ack_parent,
 .irq_mask = pci_msi_mask_irq,
 .irq_unmask = pci_msi_unmask_irq,
};

static struct msi_domain_info brcm_msi_domain_info = {

 .flags = (MSI_FLAG_USE_DEF_DOM_OPS | MSI_FLAG_USE_DEF_CHIP_OPS |
     MSI_FLAG_MULTI_PCI_MSI),
 .chip = &brcm_msi_irq_chip,
};

static void brcm_pcie_msi_isr(struct irq_desc *desc)
{
 struct irq_chip *chip = irq_desc_get_chip(desc);
 unsigned long status;
 struct brcm_msi *msi;
 struct device *dev;
 u32 bit;

 chained_irq_enter(chip, desc);
 msi = irq_desc_get_handler_data(desc);
 dev = msi->dev;

 status = readl(msi->intr_base + 0x0);
 status >>= msi->legacy_shift;

 for_each_set_bit(bit, &status, msi->nr) {
  int ret;
  ret = generic_handle_domain_irq(msi->inner_domain, bit);
  if (ret)
   dev_dbg(dev, "unexpected MSI\n");
 }

 chained_irq_exit(chip, desc);
}

static void brcm_msi_compose_msi_msg(struct irq_data *data, struct msi_msg *msg)
{
 struct brcm_msi *msi = irq_data_get_irq_chip_data(data);

 msg->address_lo = lower_32_bits(msi->target_addr);
 msg->address_hi = upper_32_bits(msi->target_addr);
 msg->data = (0xffff & 0xffe06540) | data->hwirq;
}

static int brcm_msi_set_affinity(struct irq_data *irq_data,
     const struct cpumask *mask, bool force)
{
 return -EINVAL;
}

static void brcm_msi_ack_irq(struct irq_data *data)
{
 struct brcm_msi *msi = irq_data_get_irq_chip_data(data);
 const int shift_amt = data->hwirq + msi->legacy_shift;

 writel(1 << shift_amt, msi->intr_base + 0x8);
}


static struct irq_chip brcm_msi_bottom_irq_chip = {
 .name = "BRCM STB MSI",
 .irq_compose_msi_msg = brcm_msi_compose_msi_msg,
 .irq_set_affinity = brcm_msi_set_affinity,
 .irq_ack = brcm_msi_ack_irq,
};

static int brcm_msi_alloc(struct brcm_msi *msi, unsigned int nr_irqs)
{
 int hwirq;

 mutex_lock(&msi->lock);
 hwirq = bitmap_find_free_region(msi->used, msi->nr,
     order_base_2(nr_irqs));
 mutex_unlock(&msi->lock);

 return hwirq;
}

static void brcm_msi_free(struct brcm_msi *msi, unsigned long hwirq,
     unsigned int nr_irqs)
{
 mutex_lock(&msi->lock);
 bitmap_release_region(msi->used, hwirq, order_base_2(nr_irqs));
 mutex_unlock(&msi->lock);
}

static int brcm_irq_domain_alloc(struct irq_domain *domain, unsigned int virq,
     unsigned int nr_irqs, void *args)
{
 struct brcm_msi *msi = domain->host_data;
 int hwirq, i;

 hwirq = brcm_msi_alloc(msi, nr_irqs);

 if (hwirq < 0)
  return hwirq;

 for (i = 0; i < nr_irqs; i++)
  irq_domain_set_info(domain, virq + i, hwirq + i,
        &brcm_msi_bottom_irq_chip, domain->host_data,
        handle_edge_irq, NULL, NULL);
 return 0;
}

static void brcm_irq_domain_free(struct irq_domain *domain,
     unsigned int virq, unsigned int nr_irqs)
{
 struct irq_data *d = irq_domain_get_irq_data(domain, virq);
 struct brcm_msi *msi = irq_data_get_irq_chip_data(d);

 brcm_msi_free(msi, d->hwirq, nr_irqs);
}

static const struct irq_domain_ops msi_domain_ops = {
 .alloc = brcm_irq_domain_alloc,
 .free = brcm_irq_domain_free,
};

static int brcm_allocate_domains(struct brcm_msi *msi)
{
 struct fwnode_handle *fwnode = of_node_to_fwnode(msi->np);
 struct device *dev = msi->dev;

 msi->inner_domain = irq_domain_add_linear(NULL, msi->nr, &msi_domain_ops, msi);
 if (!msi->inner_domain) {
  dev_err(dev, "failed to create IRQ domain\n");
  return -ENOMEM;
 }

 msi->msi_domain = pci_msi_create_irq_domain(fwnode,
          &brcm_msi_domain_info,
          msi->inner_domain);
 if (!msi->msi_domain) {
  dev_err(dev, "failed to create MSI domain\n");
  irq_domain_remove(msi->inner_domain);
  return -ENOMEM;
 }

 return 0;
}

static void brcm_free_domains(struct brcm_msi *msi)
{
 irq_domain_remove(msi->msi_domain);
 irq_domain_remove(msi->inner_domain);
}

static void brcm_msi_remove(struct brcm_pcie *pcie)
{
 struct brcm_msi *msi = pcie->msi;

 if (!msi)
  return;
 irq_set_chained_handler_and_data(msi->irq, NULL, NULL);
 brcm_free_domains(msi);
}

static void brcm_msi_set_regs(struct brcm_msi *msi)
{
 u32 val = msi->legacy ? GENMASK(31, 32 - 8) :
    GENMASK(32 - 1, 0);

 writel(val, msi->intr_base + 0x14);
 writel(val, msi->intr_base + 0x8);





 writel(lower_32_bits(msi->target_addr) | 0x1,
        msi->base + 0x4044);
 writel(upper_32_bits(msi->target_addr),
        msi->base + 0x4048);

 val = msi->legacy ? 0xfff86540 : 0xffe06540;
 writel(val, msi->base + 0x404c);
}

static int brcm_pcie_enable_msi(struct brcm_pcie *pcie)
{
 struct brcm_msi *msi;
 int irq, ret;
 struct device *dev = pcie->dev;

 irq = irq_of_parse_and_map(dev->of_node, 1);
 if (irq <= 0) {
  dev_err(dev, "cannot map MSI interrupt\n");
  return -ENODEV;
 }

 msi = devm_kzalloc(dev, sizeof(struct brcm_msi), GFP_KERNEL);
 if (!msi)
  return -ENOMEM;

 mutex_init(&msi->lock);
 msi->dev = dev;
 msi->base = 0xfd500000;
 msi->np = pcie->np;
 msi->target_addr = pcie->msi_target_addr;
 msi->irq = irq;
 msi->legacy = pcie->hw_rev < 0x0303;





 BUILD_BUG_ON(8 > 32);

 if (msi->legacy) {
  msi->intr_base = msi->base + 0x4300;
  msi->nr = 8;
  msi->legacy_shift = 24;
 } else {
  msi->intr_base = msi->base + 0x4500;
  msi->nr = 32;
  msi->legacy_shift = 0;
 }

 ret = brcm_allocate_domains(msi);
 if (ret)
  return ret;

 irq_set_chained_handler_and_data(msi->irq, brcm_pcie_msi_isr, msi);

 brcm_msi_set_regs(msi);
 pcie->msi = msi;

 return 0;
}


static bool brcm_pcie_rc_mode(struct brcm_pcie *pcie)
{
 void __iomem *base = 0xfd500000;
 u32 val = readl(base + 0x4068);

 return !!FIELD_GET(0x80, val);
}

static bool brcm_pcie_link_up(struct brcm_pcie *pcie)
{
 u32 val = readl(0xfd500000 + 0x4068);
 u32 dla = FIELD_GET(0x20, val);
 u32 plu = FIELD_GET(0x10, val);

 return dla && plu;
}

static void __iomem *brcm_pcie_map_bus(struct pci_bus *bus,
           unsigned int devfn, int where)
{
 struct brcm_pcie *pcie = bus->sysdata;
 void __iomem *base = 0xfd500000;
 int idx;


 if (pci_is_root_bus(bus))
  return devfn ? NULL : base + PCIE_ECAM_REG(where);


 if (!brcm_pcie_link_up(pcie))
  return NULL;


 idx = PCIE_ECAM_OFFSET(bus->number, devfn, 0);
 writel(idx, 0xfd500000 + 0x9000);
 return base + 0x8000 + PCIE_ECAM_REG(where);
}

static void __iomem *brcm7425_pcie_map_bus(struct pci_bus *bus,
        unsigned int devfn, int where)
{
 struct brcm_pcie *pcie = bus->sysdata;
 void __iomem *base = 0xfd500000;
 int idx;


 if (pci_is_root_bus(bus))
  return devfn ? NULL : base + PCIE_ECAM_REG(where);


 if (!brcm_pcie_link_up(pcie))
  return NULL;


 idx = PCIE_ECAM_OFFSET(bus->number, devfn, where);
 writel(idx, base + (0x9000));
 return base + (0x9004);
}

// set bit 1 of [0xfd509210] to val
static void brcm_pcie_bridge_sw_init_set_generic(struct brcm_pcie *pcie, u32 val)
{
 u32 tmp, mask = 0x2;
 u32 shift = 0x1;

 tmp = readl(0xfd500000 + (0x9210));
 tmp = (tmp & ~mask) | ((val << shift) & mask);
 writel(tmp, 0xfd500000 + (0x9210));
}

static void brcm_pcie_bridge_sw_init_set_7278(struct brcm_pcie *pcie, u32 val)
{
 u32 tmp, mask = 0x1;
 u32 shift = 0x0;

 tmp = readl(0xfd500000 + (0x9210));
 tmp = (tmp & ~mask) | ((val << shift) & mask);
 writel(tmp, 0xfd500000 + (0x9210));
}

static void brcm_pcie_perst_set_4908(struct brcm_pcie *pcie, u32 val)
{
 if (WARN_ONCE(!pcie->perst_reset, "missing PERST# reset controller\n"))
  return;

 if (val)
  reset_control_assert(pcie->perst_reset);
 else
  reset_control_deassert(pcie->perst_reset);
}

static void brcm_pcie_perst_set_7278(struct brcm_pcie *pcie, u32 val)
{
 u32 tmp;


 tmp = readl(0xfd500000 + 0x4064);
 u32p_replace_bits(&tmp, !val, 0x4);
 writel(tmp, 0xfd500000 + 0x4064);
}

static void brcm_pcie_perst_set_generic(struct brcm_pcie *pcie, u32 val)
{
 u32 tmp;

 tmp = readl(0xfd500000 + (0x9210));
 u32p_replace_bits(&tmp, val, 0x1);
 writel(tmp, 0xfd500000 + (0x9210));
}




static int brcm_pcie_get_rc_bar2_size_and_offset(struct brcm_pcie *pcie,
       u64 *rc_bar2_size,
       u64 *rc_bar2_offset)
{
 struct pci_host_bridge *bridge = pci_host_bridge_from_priv(pcie);
 struct resource_entry *entry;
 struct device *dev = pcie->dev;
 u64 lowest_pcie_addr = ~(u64)0;
 int ret, i = 0;
 u64 size = 0;

 resource_list_for_each_entry(entry, &bridge->dma_ranges) {
  u64 pcie_beg = entry->res->start - entry->offset;

  size += entry->res->end - entry->res->start + 1;
  if (pcie_beg < lowest_pcie_addr)
   lowest_pcie_addr = pcie_beg;
 }

 if (lowest_pcie_addr == ~(u64)0) {
  dev_err(dev, "DT node has no dma-ranges\n");
  return -EINVAL;
 }

 ret = of_property_read_variable_u64_array(pcie->np, "brcm,scb-sizes", pcie->memc_size, 1,
        3);

 if (ret <= 0) {

  pcie->num_memc = 1;
  pcie->memc_size[0] = 1ULL << fls64(size - 1);
 } else {
  pcie->num_memc = ret;
 }


 for (i = 0, size = 0; i < pcie->num_memc; i++)
  size += pcie->memc_size[i];


 *rc_bar2_offset = lowest_pcie_addr;

 *rc_bar2_size = 1ULL << fls64(size - 1);
# 855 "drivers/pci/controller/pcie-brcmstb.c"
 if (!*rc_bar2_size || (*rc_bar2_offset & (*rc_bar2_size - 1)) ||
     (*rc_bar2_offset < SZ_4G && *rc_bar2_offset > SZ_2G)) {
  dev_err(dev, "Invalid rc_bar2_offset/size: size 0x%llx, off 0x%llx\n",
   *rc_bar2_size, *rc_bar2_offset);
  return -EINVAL;
 }

 return 0;
}

static int brcm_pcie_setup(struct brcm_pcie *pcie)
{
 u64 rc_bar2_offset, rc_bar2_size;
 void __iomem *base = 0xfd500000;
 struct pci_host_bridge *bridge;
 struct resource_entry *entry;
 u32 tmp, burst, aspm_support;
 int num_out_wins = 0;
 int ret, memc;






// set bit 1 of [0xfd509210]
 pcie->bridge_sw_init_set(pcie, 1);

// sleep 100-200 microseconds
 usleep_range(100, 200);


// clear bit 1 of [0xfd509210]
 pcie->bridge_sw_init_set(pcie, 0);

// clear bit 27 of [0xfd509210]
 tmp = readl(base + 0x4204);
 tmp &= ~0x08000000;
 writel(tmp, base + 0x4204);

// sleep 100-200 microseconds
 usleep_range(100, 200);

  burst = 0x0;

// set bits 7, 10, 12, 13 and clear bits 20, 21 of [0xfd504008]
 tmp = readl(base + 0x4008);
 u32p_replace_bits(&tmp, 1, 0x1000);
 u32p_replace_bits(&tmp, 1, 0x2000);
 u32p_replace_bits(&tmp, 1, 0x400);
 u32p_replace_bits(&tmp, 1, 0x80);
 u32p_replace_bits(&tmp, burst, 0x300000);
 writel(tmp, base + 0x4008);




 ret = brcm_pcie_get_rc_bar2_size_and_offset(pcie, &rc_bar2_size,
          &rc_bar2_offset);
 if (ret)
  return ret;

 tmp = lower_32_bits(rc_bar2_offset);
 u32p_replace_bits(&tmp, brcm_pcie_encode_ibar_size(rc_bar2_size),
     0x1f);
 writel(tmp, base + 0x4034);
 writel(upper_32_bits(rc_bar2_offset),
        base + 0x4038);

 tmp = readl(base + 0x4008);
 for (memc = 0; memc < pcie->num_memc; memc++) {
  u32 scb_size_val = ilog2(pcie->memc_size[memc]) - 15;

  if (memc == 0)
   u32p_replace_bits(&tmp, scb_size_val, 0xf8000000);
  else if (memc == 1)
   u32p_replace_bits(&tmp, scb_size_val, 0x07c00000);
  else if (memc == 2)
   u32p_replace_bits(&tmp, scb_size_val, 0x0000001f);
 }
 writel(tmp, base + 0x4008);
# 954 "drivers/pci/controller/pcie-brcmstb.c"
 if (rc_bar2_offset >= SZ_4G || (rc_bar2_size + rc_bar2_offset) < SZ_4G)
  pcie->msi_target_addr = 0x0fffffffcULL;
 else
  pcie->msi_target_addr = 0xffffffffcULL;

 if (!brcm_pcie_rc_mode(pcie)) {
  dev_err(pcie->dev, "PCIe RC controller misconfigured as Endpoint\n");
  return -EINVAL;
 }


 tmp = readl(base + 0x402c);
 tmp &= ~0x1f;
 writel(tmp, base + 0x402c);


 tmp = readl(base + 0x403c);
 tmp &= ~0x1f;
 writel(tmp, base + 0x403c);


 aspm_support = PCIE_LINK_STATE_L1;
 if (!of_property_read_bool(pcie->np, "aspm-no-l0s"))
  aspm_support |= PCIE_LINK_STATE_L0S;
 tmp = readl(base + 0x04dc);
 u32p_replace_bits(&tmp, aspm_support,
  0xc00);
 writel(tmp, base + 0x04dc);





 tmp = readl(base + 0x043c);
 u32p_replace_bits(&tmp, 0x060400,
     0xffffff);
 writel(tmp, base + 0x043c);

 bridge = pci_host_bridge_from_priv(pcie);
 resource_list_for_each_entry(entry, &bridge->windows) {
  struct resource *res = entry->res;

  if (resource_type(res) != IORESOURCE_MEM)
   continue;

  if (num_out_wins >= 0x4) {
   dev_err(pcie->dev, "too many outbound wins\n");
   return -EINVAL;
  }

  if (is_bmips(pcie)) {
   u64 start = res->start;
   unsigned int j, nwins = resource_size(res) / SZ_128M;


   if (nwins > 0x4)
    nwins = 0x4;
   for (j = 0; j < nwins; j++, start += SZ_128M)
    brcm_pcie_set_outbound_win(pcie, j, start,
          start - entry->offset,
          SZ_128M);
   break;
  }
  brcm_pcie_set_outbound_win(pcie, num_out_wins, res->start,
        res->start - entry->offset,
        resource_size(res));
  num_out_wins++;
 }


 tmp = readl(base + 0x0188);
 u32p_replace_bits(&tmp, 0x0,
  0xc);
 writel(tmp, base + 0x0188);

 return 0;
}

static int brcm_pcie_start_link(struct brcm_pcie *pcie)
{
 struct device *dev = pcie->dev;
 void __iomem *base = 0xfd500000;
 u16 nlw, cls, lnksta;
 bool ssc_good = false;
 u32 tmp;
 int ret, i;


 pcie->perst_set(pcie, 0);





 msleep(100);






 for (i = 0; i < 100 && !brcm_pcie_link_up(pcie); i += 5)
  msleep(5);

 if (!brcm_pcie_link_up(pcie)) {
  dev_err(dev, "link down\n");
  return -ENODEV;
 }

 if (pcie->gen)
  brcm_pcie_set_gen(pcie, pcie->gen);

 if (pcie->ssc) {
  ret = brcm_pcie_set_ssc(pcie);
  if (ret == 0)
   ssc_good = true;
  else
   dev_err(dev, "failed attempt to enter ssc mode\n");
 }

 lnksta = readw(base + 0x00ac + PCI_EXP_LNKSTA);
 cls = FIELD_GET(PCI_EXP_LNKSTA_CLS, lnksta);
 nlw = FIELD_GET(PCI_EXP_LNKSTA_NLW, lnksta);
 dev_info(dev, "link up, %s x%u %s\n",
   pci_speed_string(pcie_link_speed[cls]), nlw,
   ssc_good ? "(SSC)" : "(!SSC)");





 tmp = readl(base + 0x4204);
 tmp |= 0x2;
 writel(tmp, base + 0x4204);

 return 0;
}

static const char * const supplies[] = {
 "vpcie3v3",
 "vpcie3v3aux",
 "vpcie12v",
};

static void *alloc_subdev_regulators(struct device *dev)
{
 const size_t size = sizeof(struct subdev_regulators) +
  sizeof(struct regulator_bulk_data) * ARRAY_SIZE(supplies);
 struct subdev_regulators *sr;
 int i;

 sr = devm_kzalloc(dev, size, GFP_KERNEL);
 if (sr) {
  sr->num_supplies = ARRAY_SIZE(supplies);
  for (i = 0; i < ARRAY_SIZE(supplies); i++)
   sr->supplies[i].supply = supplies[i];
 }

 return sr;
}

static int brcm_pcie_add_bus(struct pci_bus *bus)
{
 struct brcm_pcie *pcie = bus->sysdata;
 struct device *dev = &bus->dev;
 struct subdev_regulators *sr;
 int ret;

 if (!bus->parent || !pci_is_root_bus(bus->parent))
  return 0;

 if (dev->of_node) {
  sr = alloc_subdev_regulators(dev);
  if (!sr) {
   dev_info(dev, "Can't allocate regulators for downstream device\n");
   goto no_regulators;
  }

  pcie->sr = sr;

  ret = regulator_bulk_get(dev, sr->num_supplies, sr->supplies);
  if (ret) {
   dev_info(dev, "No regulators for downstream device\n");
   goto no_regulators;
  }

  ret = regulator_bulk_enable(sr->num_supplies, sr->supplies);
  if (ret) {
   dev_err(dev, "Can't enable regulators for downstream device\n");
   regulator_bulk_free(sr->num_supplies, sr->supplies);
   pcie->sr = NULL;
  }
 }

no_regulators:
 brcm_pcie_start_link(pcie);
 return 0;
}

static void brcm_pcie_remove_bus(struct pci_bus *bus)
{
 struct brcm_pcie *pcie = bus->sysdata;
 struct subdev_regulators *sr = pcie->sr;
 struct device *dev = &bus->dev;

 if (!sr)
  return;

 if (regulator_bulk_disable(sr->num_supplies, sr->supplies))
  dev_err(dev, "Failed to disable regulators for downstream device\n");
 regulator_bulk_free(sr->num_supplies, sr->supplies);
 pcie->sr = NULL;
}


static void brcm_pcie_enter_l23(struct brcm_pcie *pcie)
{
 void __iomem *base = 0xfd500000;
 int l23, i;
 u32 tmp;


 tmp = readl(base + 0x4064);
 u32p_replace_bits(&tmp, 1, 0x1);
 writel(tmp, base + 0x4064);


 tmp = readl(base + 0x4068);
 l23 = FIELD_GET(0x40, tmp);
 for (i = 0; i < 15 && !l23; i++) {
  usleep_range(2000, 2400);
  tmp = readl(base + 0x4068);
  l23 = FIELD_GET(0x40,
    tmp);
 }

 if (!l23)
  dev_err(pcie->dev, "failed to enter low-power link state\n");
}

static int brcm_phy_cntl(struct brcm_pcie *pcie, const int start)
{
 static const u32 shifts[0x3] = {
  0x0,
  0x1,
  0x2,};
 static const u32 masks[0x3] = {
  0x1,
  0x2,
  0x4,};
 const int beg = start ? 0 : 0x3 - 1;
 const int end = start ? 0x3 : -1;
 u32 tmp, combined_mask = 0;
 u32 val;
 void __iomem *base = 0xfd500000;
 int i, ret;

 for (i = beg; i != end; start ? i++ : i--) {
  val = start ? BIT_MASK(shifts[i]) : 0;
  tmp = readl(base + 0xc700);
  tmp = (tmp & ~masks[i]) | (val & masks[i]);
  writel(tmp, base + 0xc700);
  usleep_range(50, 200);
  combined_mask |= masks[i];
 }

 tmp = readl(base + 0xc700);
 val = start ? combined_mask : 0;

 ret = (tmp & combined_mask) == val ? 0 : -EIO;
 if (ret)
  dev_err(pcie->dev, "failed to %s phy\n", (start ? "start" : "stop"));

 return ret;
}

static inline int brcm_phy_start(struct brcm_pcie *pcie)
{
 return pcie->rescal ? brcm_phy_cntl(pcie, 1) : 0;
}

static inline int brcm_phy_stop(struct brcm_pcie *pcie)
{
 return pcie->rescal ? brcm_phy_cntl(pcie, 0) : 0;
}

static void brcm_pcie_turn_off(struct brcm_pcie *pcie)
{
 void __iomem *base = 0xfd500000;
 int tmp;

 if (brcm_pcie_link_up(pcie))
  brcm_pcie_enter_l23(pcie);

 pcie->perst_set(pcie, 1);


 tmp = readl(base + 0x4064);
 u32p_replace_bits(&tmp, 0, 0x1);
 writel(tmp, base + 0x4064);


 tmp = readl(base + 0x4204);
 u32p_replace_bits(&tmp, 1, 0x08000000);
 writel(tmp, base + 0x4204);


 pcie->bridge_sw_init_set(pcie, 1);
}

static int pci_dev_may_wakeup(struct pci_dev *dev, void *data)
{
 bool *ret = data;

 if (device_may_wakeup(&dev->dev)) {
  *ret = true;
  dev_info(&dev->dev, "Possible wake-up device; regulators will not be disabled\n");
 }
 return (int) *ret;
}

static int brcm_pcie_suspend_noirq(struct device *dev)
{
 struct brcm_pcie *pcie = dev_get_drvdata(dev);
 struct pci_host_bridge *bridge = pci_host_bridge_from_priv(pcie);
 int ret;

 brcm_pcie_turn_off(pcie);





 if (brcm_phy_stop(pcie))
  dev_err(dev, "Could not stop phy for suspend\n");

 ret = reset_control_rearm(pcie->rescal);
 if (ret) {
  dev_err(dev, "Could not rearm rescal reset\n");
  return ret;
 }

 if (pcie->sr) {





  pcie->ep_wakeup_capable = false;
  pci_walk_bus(bridge->bus, pci_dev_may_wakeup,
        &pcie->ep_wakeup_capable);
  if (!pcie->ep_wakeup_capable) {
   ret = regulator_bulk_disable(pcie->sr->num_supplies,
           pcie->sr->supplies);
   if (ret) {
    dev_err(dev, "Could not turn off regulators\n");
    reset_control_reset(pcie->rescal);
    return ret;
   }
  }
 }
 clk_disable_unprepare(pcie->clk);

 return 0;
}

static int brcm_pcie_resume_noirq(struct device *dev)
{
 struct brcm_pcie *pcie = dev_get_drvdata(dev);
 void __iomem *base;
 u32 tmp;
 int ret;

 base = 0xfd500000;
 ret = clk_prepare_enable(pcie->clk);
 if (ret)
  return ret;

 ret = reset_control_reset(pcie->rescal);
 if (ret)
  goto err_disable_clk;

 ret = brcm_phy_start(pcie);
 if (ret)
  goto err_reset;


 pcie->bridge_sw_init_set(pcie, 0);


 tmp = readl(base + 0x4204);
 u32p_replace_bits(&tmp, 0, 0x08000000);
 writel(tmp, base + 0x4204);


 udelay(100);

 ret = brcm_pcie_setup(pcie);
 if (ret)
  goto err_reset;

 if (pcie->sr) {
  if (pcie->ep_wakeup_capable) {






   pcie->ep_wakeup_capable = false;
  } else {
   ret = regulator_bulk_enable(pcie->sr->num_supplies,
          pcie->sr->supplies);
   if (ret) {
    dev_err(dev, "Could not turn on regulators\n");
    goto err_reset;
   }
  }
 }

 ret = brcm_pcie_start_link(pcie);
 if (ret)
  goto err_regulator;

 if (pcie->msi)
  brcm_msi_set_regs(pcie->msi);

 return 0;

err_regulator:
 if (pcie->sr)
  regulator_bulk_disable(pcie->sr->num_supplies, pcie->sr->supplies);
err_reset:
 reset_control_rearm(pcie->rescal);
err_disable_clk:
 clk_disable_unprepare(pcie->clk);
 return ret;
}

static void __brcm_pcie_remove(struct brcm_pcie *pcie)
{
 brcm_msi_remove(pcie);
 brcm_pcie_turn_off(pcie);
 if (brcm_phy_stop(pcie))
  dev_err(pcie->dev, "Could not stop phy\n");
 if (reset_control_rearm(pcie->rescal))
  dev_err(pcie->dev, "Could not rearm rescal reset\n");
 clk_disable_unprepare(pcie->clk);
}

static int brcm_pcie_remove(struct platform_device *pdev)
{
 struct brcm_pcie *pcie = platform_get_drvdata(pdev);
 struct pci_host_bridge *bridge = pci_host_bridge_from_priv(pcie);

 pci_stop_root_bus(bridge->bus);
 pci_remove_root_bus(bridge->bus);
 __brcm_pcie_remove(pcie);

 return 0;
}

static const int pcie_offsets[] = {
 [0] = 0x9210,
 [1] = 0x9000,
 [2] = 0x9004,
};

static const int pcie_offsets_bmips_7425[] = {
 [0] = 0x8010,
 [1] = 0x8300,
 [2] = 0x8304,
};

static const struct pcie_cfg_data generic_cfg = {
 .offsets = pcie_offsets,
 .type = GENERIC,
 .perst_set = brcm_pcie_perst_set_generic,
 .bridge_sw_init_set = brcm_pcie_bridge_sw_init_set_generic,
};

static const struct pcie_cfg_data bcm7425_cfg = {
 .offsets = pcie_offsets_bmips_7425,
 .type = BCM7425,
 .perst_set = brcm_pcie_perst_set_generic,
 .bridge_sw_init_set = brcm_pcie_bridge_sw_init_set_generic,
};

static const struct pcie_cfg_data bcm7435_cfg = {
 .offsets = pcie_offsets,
 .type = BCM7435,
 .perst_set = brcm_pcie_perst_set_generic,
 .bridge_sw_init_set = brcm_pcie_bridge_sw_init_set_generic,
};

static const struct pcie_cfg_data bcm4908_cfg = {
 .offsets = pcie_offsets,
 .type = BCM4908,
 .perst_set = brcm_pcie_perst_set_4908,
 .bridge_sw_init_set = brcm_pcie_bridge_sw_init_set_generic,
};

static const int pcie_offset_bcm7278[] = {
 [0] = 0xc010,
 [1] = 0x9000,
 [2] = 0x9004,
};

static const struct pcie_cfg_data bcm7278_cfg = {
 .offsets = pcie_offset_bcm7278,
 .type = BCM7278,
 .perst_set = brcm_pcie_perst_set_7278,
 .bridge_sw_init_set = brcm_pcie_bridge_sw_init_set_7278,
};

static const struct pcie_cfg_data bcm2711_cfg = {
 .offsets = pcie_offsets,
 .type = BCM2711,
 .perst_set = brcm_pcie_perst_set_generic,
 .bridge_sw_init_set = brcm_pcie_bridge_sw_init_set_generic,
};

static const struct of_device_id brcm_pcie_match[] = {
 { .compatible = "brcm,bcm2711-pcie", .data = &bcm2711_cfg },
 { .compatible = "brcm,bcm4908-pcie", .data = &bcm4908_cfg },
 { .compatible = "brcm,bcm7211-pcie", .data = &generic_cfg },
 { .compatible = "brcm,bcm7278-pcie", .data = &bcm7278_cfg },
 { .compatible = "brcm,bcm7216-pcie", .data = &bcm7278_cfg },
 { .compatible = "brcm,bcm7445-pcie", .data = &generic_cfg },
 { .compatible = "brcm,bcm7435-pcie", .data = &bcm7435_cfg },
 { .compatible = "brcm,bcm7425-pcie", .data = &bcm7425_cfg },
 {},
};

static struct pci_ops brcm_pcie_ops = {
 .map_bus = brcm_pcie_map_bus,
 .read = pci_generic_config_read,
 .write = pci_generic_config_write,
 .add_bus = brcm_pcie_add_bus,
 .remove_bus = brcm_pcie_remove_bus,
};

static struct pci_ops brcm7425_pcie_ops = {
 .map_bus = brcm7425_pcie_map_bus,
 .read = pci_generic_config_read32,
 .write = pci_generic_config_write32,
 .add_bus = brcm_pcie_add_bus,
 .remove_bus = brcm_pcie_remove_bus,
};

static int brcm_pcie_probe(struct platform_device *pdev)
{
 struct device_node *np = pdev->dev.of_node, *msi_np;
 struct pci_host_bridge *bridge;
 const struct pcie_cfg_data *data;
 struct brcm_pcie *pcie;
 int ret;

 bridge = devm_pci_alloc_host_bridge(&pdev->dev, sizeof(*pcie));
 if (!bridge)
  return -ENOMEM;

 data = of_device_get_match_data(&pdev->dev);
 if (!data) {
  pr_err("failed to look up compatible string\n");
  return -EINVAL;
 }

 pcie = pci_host_bridge_priv(bridge);
 pcie->dev = &pdev->dev;
 pcie->np = np;
 pcie->reg_offsets = data->offsets;
 pcie->type = data->type;
 pcie->perst_set = data->perst_set;
 pcie->bridge_sw_init_set = data->bridge_sw_init_set;

 0xfd500000 = devm_platform_ioremap_resource(pdev, 0);
 if (IS_ERR(0xfd500000))
  return PTR_ERR(0xfd500000);

 pcie->clk = devm_clk_get_optional(&pdev->dev, "sw_pcie");
 if (IS_ERR(pcie->clk))
  return PTR_ERR(pcie->clk);

 ret = of_pci_get_max_link_speed(np);
 pcie->gen = (ret < 0) ? 0 : ret;

 pcie->ssc = of_property_read_bool(np, "brcm,enable-ssc");

 ret = clk_prepare_enable(pcie->clk);
 if (ret) {
  dev_err(&pdev->dev, "could not enable clock\n");
  return ret;
 }
 pcie->rescal = devm_reset_control_get_optional_shared(&pdev->dev, "rescal");
 if (IS_ERR(pcie->rescal)) {
  clk_disable_unprepare(pcie->clk);
  return PTR_ERR(pcie->rescal);
 }
 pcie->perst_reset = devm_reset_control_get_optional_exclusive(&pdev->dev, "perst");
 if (IS_ERR(pcie->perst_reset)) {
  clk_disable_unprepare(pcie->clk);
  return PTR_ERR(pcie->perst_reset);
 }

 ret = reset_control_reset(pcie->rescal);
 if (ret)
  dev_err(&pdev->dev, "failed to deassert 'rescal'\n");

 ret = brcm_phy_start(pcie);
 if (ret) {
  reset_control_rearm(pcie->rescal);
  clk_disable_unprepare(pcie->clk);
  return ret;
 }

 ret = brcm_pcie_setup(pcie);
 if (ret)
  goto fail;

 pcie->hw_rev = readl(0xfd500000 + 0x406c);
 if (pcie->type == BCM4908 && pcie->hw_rev >= 0x0320) {
  dev_err(pcie->dev, "hardware revision with unsupported PERST# setup\n");
  ret = -ENODEV;
  goto fail;
 }

 msi_np = of_parse_phandle(pcie->np, "msi-parent", 0);
 if (pci_msi_enabled() && msi_np == pcie->np) {
  ret = brcm_pcie_enable_msi(pcie);
  if (ret) {
   dev_err(pcie->dev, "probe of internal MSI failed");
   goto fail;
  }
 }

 bridge->ops = pcie->type == BCM7425 ? &brcm7425_pcie_ops : &brcm_pcie_ops;
 bridge->sysdata = pcie;

 platform_set_drvdata(pdev, pcie);

 ret = pci_host_probe(bridge);
 if (!ret && !brcm_pcie_link_up(pcie))
  ret = -ENODEV;

 if (ret) {
  brcm_pcie_remove(pdev);
  return ret;
 }

 return 0;

fail:
 __brcm_pcie_remove(pcie);
 return ret;
}

MODULE_DEVICE_TABLE(of, brcm_pcie_match);

static const struct dev_pm_ops brcm_pcie_pm_ops = {
 .suspend_noirq = brcm_pcie_suspend_noirq,
 .resume_noirq = brcm_pcie_resume_noirq,
};

static struct platform_driver brcm_pcie_driver = {
 .probe = brcm_pcie_probe,
 .remove = brcm_pcie_remove,
 .driver = {
  .name = "brcm-pcie",
  .of_match_table = brcm_pcie_match,
  .pm = &brcm_pcie_pm_ops,
 },
};
module_platform_driver(brcm_pcie_driver);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Broadcom STB PCIe RC driver");
MODULE_AUTHOR("Broadcom");
