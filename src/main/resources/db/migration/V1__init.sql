CREATE TABLE trainer (
    id UUID PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE owned_pokemon (
    id UUID PRIMARY KEY,
    trainer_id UUID NOT NULL,
    species_name VARCHAR(50) NOT NULL,
    pokeapi_id INTEGER,
    nickname VARCHAR(50),
    level INTEGER NOT NULL DEFAULT 1,
    shiny BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL,
    acquired_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_owned_pokemon_trainer
        FOREIGN KEY (trainer_id)
        REFERENCES trainer(id)
        ON DELETE CASCADE
);

CREATE TABLE trade (
    id UUID PRIMARY KEY,
    initiator_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT fk_trade_initiator
        FOREIGN KEY (initiator_id)
        REFERENCES trainer(id),

    CONSTRAINT fk_trade_recipient
        FOREIGN KEY (recipient_id)
        REFERENCES trainer(id)
);

CREATE TABLE trade_pokemon (
    trade_id UUID NOT NULL,
    owned_pokemon_id UUID NOT NULL,
    role VARCHAR(20) NOT NULL,

    PRIMARY KEY (trade_id, owned_pokemon_id),

    CONSTRAINT fk_trade_pokemon_trade
        FOREIGN KEY (trade_id)
        REFERENCES trade(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_trade_pokemon_owned
        FOREIGN KEY (owned_pokemon_id)
        REFERENCES owned_pokemon(id)
);

CREATE TABLE trade_offer (
    id UUID PRIMARY KEY,
    sender_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    offered_pokemon_id UUID NOT NULL,
    requested_species VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    ai_analysis TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,

    CONSTRAINT fk_trade_offer_sender
        FOREIGN KEY (sender_id)
        REFERENCES trainer(id),

    CONSTRAINT fk_trade_offer_recipient
        FOREIGN KEY (recipient_id)
        REFERENCES trainer(id),

    CONSTRAINT fk_trade_offer_pokemon
        FOREIGN KEY (offered_pokemon_id)
        REFERENCES owned_pokemon(id)
);

CREATE TABLE sale_listing (
    id UUID PRIMARY KEY,
    pokemon_id UUID NOT NULL UNIQUE,
    seller_id UUID NOT NULL,
    buyer_id UUID,
    price NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP,

    CONSTRAINT fk_listing_pokemon
        FOREIGN KEY (pokemon_id)
        REFERENCES owned_pokemon(id),

    CONSTRAINT fk_listing_seller
        FOREIGN KEY (seller_id)
        REFERENCES trainer(id),

    CONSTRAINT fk_listing_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES trainer(id)
);

CREATE TABLE user_account (
    id UUID PRIMARY KEY,
    trainer_id UUID NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_trainer
        FOREIGN KEY (trainer_id)
        REFERENCES trainer(id)
        ON DELETE CASCADE
);

