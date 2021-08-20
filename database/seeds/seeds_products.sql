-- Banco diz que já existe produtos com o mesmo nome, então dei drop nessa function e no final crio novamente
drop function control_duplicate_product_with_same_name_trigger cascade;

-- Food
do $$
declare varFood varchar[] = '{Breads,
Cornmeal,
Cream_of_wheat,
Croutons,
Flour,
Oatmeal,
Pasta,
Pita_bread,
Rice,
Tortilla,
Beans,
Hummus,
Nuts,
Corn,
Peas,
Potato,
Sweet_potato,
Almond_milk,
Cow’s_milk,
Soy_milk,
Yogurt,
Applesauce,
Apricots,
Banana,
Blackberries,
Cherries,
Fruit_cocktail,
Grapefruit,
Grapes,
Kiwi,
Mango,
Melons,
Orange,
Peaches,
Pear,
Pineapple,
Plum,
Prunes,
Raisins,
Raspberries,
Strawberries,
Watermelon,
French_fries,
Graham,
Popcorn,
Potato_chips,
Tortilla_chips,
Barbeque,
Fruit,
Honey,
Honey,
Ketchup,
Mayonnaise,
Peanut,
Ranch,
Salsa,
Sugar,
Sauce}';
begin
	for i in 1..58 loop
		INSERT INTO public.products (id, "name", image, unit, category, created_at, updated_at)
		values (uuid_generate_v4(), varFood[i], null, 'box', 'food', now(), now());
	end loop;
end; $$
language plpgsql;

-- Objects
do $$
declare varObject varchar[] := '{Aroma_lamp
,Beverage_opener
,Appliance_plug
,Paintbrush
,Roller
,Hair_dryer
,Toaster
,Electric_kettle
,Television
,Stove
,Small_oven
,Microwave_oven
,Evaporative_cooler
,Air_conditioner
,Vacuum_cleaner
,Water_cooler
,Clock
,Sewing_machine
,Fan
,Juicer
,Clothes_iron
,Blender
,Mousetrap
,Bachelor_griller
,Washing_machine
,Refrigerator
,Stepladder
,Treadmill
,Bulb
,Wall_lantern
,Hanging_pendant
,Anglepoise_lamp
,Candleholder
,Telephone
,Remote
,Fan}';
begin
	for i in 1..36 loop
		INSERT INTO public.products (id, "name", image, unit, category, created_at, updated_at)
		values (uuid_generate_v4(), varObject[i], null, 'un', 'object', now(), now());
	end loop;
end; $$
language plpgsql;

-- Eletronics
do $$
declare varEletronic varchar[] := '{Air_purifier
,Air_conditioner
,Alarm_clock
,Backup_charger
,Bread_maker
,Banknote_counter
,Blender
,Bluetooth_speaker
,Bulb
,Calculator
,Car_toy
,Ceiling_fan
,Chandelier
,Clock
,Clothes_dryer
,Coffee_maker
,Computer
,Copier
,Curling_iron
,Digital_camera
,Dishwasher
,Doorbell_camera
,Drill
,Dvd_player
,Earphones
,Electric_frying_pan
,Electric_grill
,Electric_guitar
,Electric_pencil_sharpener
,Electric_razor
,Electric_stove
,Exhaust_fan
,External_hard_drive
,Fan
,Facial_cleansing_machine
,Fax
,Fish_tank
,Floor_lamp
,Game_controller
,Garage
,Grandfather_clock
,Hair_dryer
,Headset
,Inkjet_printer
,iPod
,Iron
,Juicer
,Kettle
,Kitchen_scale
,Hair_straightening_machine
,Laser_printer
,Lawn_mower
,Lift
,Meat_grinder
,Microphone
,Microwave
,Mixer
,Monitor
,Mosquito_racket
,Mouse
,Mp3_player
,Oil-free_fryer
,Piano
,Oven
,Plotter
,Pressure_cooker
,Printer
,Projector
,Radiator
,Radio
,Reading_lamp
,Refrigerator
,Remote_control
,Rice_cooker
,Safe
,Robotic_vacuum_cleaner
,Sandwich_maker
,Scale
,Scanner
,Sewing_machine
,Smart_television
,Smartphone
,Speakers
,Tablet
,Television
,Timer
,Toaster
,Torch
,USB_drive
,Vacuum_cleaner
,Walkie-talkie
,Washing_machine
,Watch
,Water_pumps
,Water_purifier
,Wall_fan
,Water_heater
,Webcam
,Wifi_modem}';
begin
	for i in 1..99 loop
		INSERT INTO public.products (id, "name", image, unit, category, created_at, updated_at)
		values (uuid_generate_v4(), varEletronic[i], null, 'un', 'eletronic', now(), now());
	end loop;
end; $$
language plpgsql;

-- Clothes
do $$
declare varClothing varchar[] := '{beie,
belt,
beret,
bikini,
blazer,
blouse,
bra,
brooch,
button,
cap,
cardig,
vest,
chain,
coat,
coat,
diamond,
dinner,
jacket,
dress,
fashion,
designer,
fashion,
houseshow,
frock,
dres,
skirt,
hdkerchief,
hat,
hem,
hook,
hue,
jacket,
jersey,
jeweller,
jogging,
suit,
model,
necklace,
needle,
nightdress,
patch,
pattern,
pin,
pullover,
sweater,
jumper,
raincoat,
real,
pearl,
ruby,
sapphire,
scarf,
seam,
sewing,
machine,
shade,
shawl,
shirt,
ski,
jacket,
skirt,
sleeve,
slip,
stitch,
suit,
suspended,
belt,
sweater,
jumper,
pullover,
sweatshirt,
t_shirt,
tailor,
thimble,
tie,
top,
tuxedo,
diner,
jacket,
smoking,
uniform,
watch,
wedding,
ring,
fastener,
amethyst,
apron,
emerald,
engagement,
ring,
outfit,
dress,
blouse,
boots,
bow,
tie,
bowler,
hat,
boxer,
shorts,
braces,
briefs,
casual,
dress,
checked,
clothing,
cufflinks,
cultured,
pearls,
discreet,
dressing_gown,
bath,
robe,
earrings,
counterfeit,
fashionable,
trendy,
formal,
dress,
gaudy,
genuine,
gloves,
jewellery,
knickers,
leather,
jacket,
light,
loose,
clothes,
miniskirt,
neat,
nightgown,
nightdress,
old_fashioned,
out_of_date,
overalls,
boiler_suit,
overcoat,
pajamas,
trousers,
pastel,
pleated,
skirt,
pyjamas,
rumpled,
sewing,
shabby,
threadbare,
shorts,
slippers,
smart,
elegt,
sober,
socks,
stockings,
straight,
skirt,
suitable,
swimming,
cap,
swimming,
trunks,
bathing,
suit,
collar,
thread,
tights,
tracksuit,
triped,
undershirt,
underwear,
underpts,
washable,
well_cut,
well_dressed}';
begin
	for i in 1..100 loop
		INSERT INTO public.products (id, "name", image, unit, category, created_at, updated_at)
		values (uuid_generate_v4(), varClothing[i], null, 'un', 'clothing', now(), now());
	end loop;
end; $$
language plpgsql;

-- Cria novamente a função
CREATE OR REPLACE FUNCTION public.control_duplicate_product_with_same_name_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$ BEGIN IF EXISTS(
        SELECT name
        FROM public.products
        WHERE unaccent(name) = unaccent(NEW.name)
    ) THEN RAISE EXCEPTION 'product already registered.';
ELSE RETURN NEW;
END IF;
END;
$function$
;
